import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_info.dart';

/// Auth service using Keycloak's Resource Owner Password Credentials (ROPC) flow.
/// Authenticates directly with username/password — no external browser needed.
///
/// Uses [SharedPreferences] (not FlutterSecureStorage) for token persistence.
/// On Android, FlutterSecureStorage's Keystore encryption can corrupt long JWT
/// strings (~1000+ chars) when read back. SharedPreferences stores plaintext,
/// which is safe for a mobile client token.
///
/// The access token is also cached in memory to avoid any storage read during
/// the active session. Storage is only consulted on app restart.
class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  static const _keycloakUrl = 'http://localhost:8082';
  static const _realm = 'hospital-hms';
  static const _clientId = 'hospital-mobile';

  static const _accessTokenKey = 'keycloak_access_token';
  static const _refreshTokenKey = 'keycloak_refresh_token';

  final _authStateController = StreamController<AuthState>.broadcast();
  final _userController = StreamController<UserInfo?>.broadcast();

  AuthState _authState = AuthState.unknown;
  UserInfo? _currentUser;

  /// In-memory cache of the access token — avoids storage reads during session.
  String? _accessToken;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthChange => _authStateController.stream;

  /// Stream of user info changes.
  Stream<UserInfo?> get onUserChange => _userController.stream;

  /// Current auth state.
  AuthState get authState => _authState;

  /// Whether the user is signed in.
  bool get isSignedIn => _authState == AuthState.signedIn;

  /// Current authenticated user info, or null.
  UserInfo? get currentUser => _currentUser;

  /// Resolve Keycloak URL considering platform.
  String get _resolvedKeycloakUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8082';
    }
    return _keycloakUrl;
  }

  String get _tokenEndpoint =>
      '$_resolvedKeycloakUrl/realms/$_realm/protocol/openid-connect/token';

  /// Initialize — restore saved session if available.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_accessTokenKey);
      var refreshToken = prefs.getString(_refreshTokenKey);

      if (_accessToken != null && _accessToken!.isNotEmpty) {
        if (!_isTokenExpired(_accessToken!)) {
          // Token is still valid — restore session immediately
          _setAuthenticated(_accessToken!);
          // Proactive background refresh for near-expiry tokens
          _tryRefreshInBackground();
        } else if (refreshToken != null && refreshToken.isNotEmpty) {
          // Token is expired — try to refresh before restoring session
          final refreshed = await _tryRefresh();
          if (!refreshed) {
            // Refresh failed — clear stale tokens and stay signed out
            _accessToken = null;
            await prefs.remove(_accessTokenKey);
            await prefs.remove(_refreshTokenKey);
            _setAuthState(AuthState.signedOut);
          }
        } else {
          // Token expired, no refresh token — clear and sign out
          _accessToken = null;
          await prefs.remove(_accessTokenKey);
          _setAuthState(AuthState.signedOut);
        }
      } else {
        _setAuthState(AuthState.signedOut);
      }
    } catch (e) {
      debugPrint('Auth init failed: $e');
      _accessToken = null;
      _setAuthState(AuthState.signedOut);
    }
  }

  /// Shared refresh logic: POST the stored refresh token to Keycloak.
  /// Returns true if the refresh succeeded and [accessToken] was updated.
  Future<bool> _tryRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;

        _accessToken = newAccessToken;
        await prefs.setString(_accessTokenKey, newAccessToken);
        if (newRefreshToken != null) {
          await prefs.setString(_refreshTokenKey, newRefreshToken);
        }

        _setAuthenticated(newAccessToken);
        return true;
      }

      debugPrint('Token refresh failed (HTTP ${response.statusCode})');
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Attempt a background token refresh — silent fail is fine.
  Future<void> _tryRefreshInBackground() async {
    await _tryRefresh();
  }

  /// Log in with username and password using the ROPC flow.
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': _clientId,
        'username': username,
        'password': password,
        'grant_type': 'password',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;

      // Cache in memory first (always clean — just received from server)
      _accessToken = accessToken;

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }

      _setAuthenticated(accessToken);
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error_description'] as String? ??
          data['error'] as String? ??
          'Login failed (${response.statusCode})';
      throw AuthException(error);
    }
  }

  /// Log the user out.
  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _currentUser = null;
    _userController.add(null);
    _setAuthState(AuthState.signedOut);
  }

  /// Decode the JWT payload (second segment) and return the expiry timestamp.
  int? _getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['exp'] as int?;
    } catch (_) {
      return null;
    }
  }

  /// Check whether a JWT access token is expired (or expires within the buffer).
  bool _isTokenExpired(String token, {int bufferSeconds = 60}) {
    final exp = _getTokenExpiry(token);
    if (exp == null) return true; // Can't decode — assume expired
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= (exp - bufferSeconds);
  }

  /// Get a valid access token, or null if not authenticated.
  ///
  /// Returns the in-memory cached token first. Never re-reads from
  /// [SharedPreferences] during an active session. Only falls back to storage
  /// if the in-memory cache is empty (e.g., after app restart).
  Future<String?> getAccessToken() async {
    if (!isSignedIn) return null;

    // Use in-memory cache first — avoids storage reads during the session.
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      if (!_isTokenExpired(_accessToken!)) {
        return _accessToken;
      }
    }

    // No valid in-memory token — try to restore from storage (app restart case)
    if (_accessToken == null || _accessToken!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_accessTokenKey);
      if (_accessToken == null || _accessToken!.isEmpty) {
        await logout();
        return null;
      }
      if (!_isTokenExpired(_accessToken!)) {
        _setAuthenticated(_accessToken!);
        return _accessToken;
      }
    }

    // Token is expired — try to refresh
    final refreshed = await _tryRefresh();
    if (refreshed) {
      return _accessToken;
    }

    // Refresh failed — log out and return null so the UI redirects to login
    debugPrint('Token refresh failed — logging out');
    await logout();
    return null;
  }

  void _setAuthenticated(String accessToken) {
    _accessToken = accessToken;
    _currentUser = UserInfo.fromJwt(accessToken);
    _userController.add(_currentUser);
    _setAuthState(AuthState.signedIn);
  }

  void _setAuthState(AuthState state) {
    _authState = state;
    _authStateController.add(state);
  }

  /// Dispose the service.
  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}

/// Exception thrown during authentication.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
