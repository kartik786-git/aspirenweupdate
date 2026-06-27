import 'dart:convert';

/// Represents the authenticated user's information decoded from the JWT.
class UserInfo {
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;

  UserInfo({
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.roles = const [],
  });

  String get displayName => firstName ?? lastName ?? username;
  String get initials => (firstName?.isNotEmpty == true
          ? firstName![0]
          : username.isNotEmpty
              ? username[0]
              : '?')
      .toUpperCase();

  /// Decode a JWT access token and extract user info.
  factory UserInfo.fromJwt(String accessToken) {
    try {
      // JWT payload is the second segment (base64-encoded JSON)
      final parts = accessToken.split('.');
      if (parts.length < 2) {
        return UserInfo(username: 'unknown');
      }

      // Add padding if needed
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

      final realmAccess = json['realm_access'] as Map<String, dynamic>?;
      final roles = realmAccess?['roles'] as List<dynamic>?;

      return UserInfo(
        username: json['preferred_username'] as String? ?? 'unknown',
        email: json['email'] as String?,
        firstName: json['given_name'] as String?,
        lastName: json['family_name'] as String?,
        roles: roles?.cast<String>() ?? [],
      );
    } catch (_) {
      return UserInfo(username: 'unknown');
    }
  }
}

/// Authentication state enum.
enum AuthState {
  unknown,
  signedOut,
  signedIn,
}
