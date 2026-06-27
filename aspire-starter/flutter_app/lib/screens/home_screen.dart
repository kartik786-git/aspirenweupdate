import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_info.dart' show UserInfo;
import 'dashboard_screen.dart';
import 'patients_list_screen.dart';
import 'doctors_list_screen.dart';
import 'appointments_list_screen.dart';
import 'departments_list_screen.dart';
import 'medical_records_list_screen.dart';
import 'billing_list_screen.dart';
import 'rooms_list_screen.dart';
import 'staff_list_screen.dart';

/// Responsive navigation shell — sidebar (NavigationRail) on wide/web screens,
/// bottom navigation bar on narrow/mobile screens. All 9 screens share the
/// same IndexedStack so the user can navigate freely.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  static const _titles = [
    'Dashboard', 'Patients', 'Doctors', 'Appointments',
    'Departments', 'Medical Records', 'Billing', 'Rooms', 'Staff',
  ];

  static const _icons = <IconData>[
    Icons.dashboard_rounded, Icons.people_rounded, Icons.medical_services_rounded,
    Icons.calendar_month_rounded, Icons.business_rounded, Icons.description_rounded,
    Icons.receipt_long_rounded, Icons.meeting_room_rounded, Icons.badge_rounded,
  ];

  /// Preserved once to keep IndexedStack child state across tab switches.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(embedded: false, onNavigate: _handleNavigate),
      const PatientsListScreen(),
      const DoctorsListScreen(),
      const AppointmentsListScreen(),
      const DepartmentsListScreen(),
      const MedicalRecordsListScreen(),
      const BillingListScreen(),
      const RoomsListScreen(),
      const StaffListScreen(),
    ];
  }

  void _handleNavigate(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    // ── Wide / Web layout ──────────────────────────────────────────
    if (isWide) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo area
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_hospital, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'HospiCare',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Navigation items — takes all remaining space above user info
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(9, (i) {
                          final sel = _currentIndex == i;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: sel ? const Color(0xFF2563EB).withAlpha(12) : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                _icons[i],
                                color: sel ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                size: 22,
                              ),
                              title: Text(
                                _titles[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                                  color: sel ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                ),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onTap: () => setState(() => _currentIndex = i),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // User info & logout
                  StreamBuilder<UserInfo?>(
                    initialData: AuthService.instance.currentUser,
                    stream: AuthService.instance.onUserChange,
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF2563EB).withAlpha(25),
                                child: Text(
                                  user?.initials ?? '?',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              title: Text(
                                user?.displayName ?? 'User',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              subtitle: user?.email != null
                                  ? Text(user!.email!, style: const TextStyle(fontSize: 11))
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(Icons.logout, size: 16, color: Color(0xFFEF4444)),
                                label: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                                onPressed: () async => await AuthService.instance.logout(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  title: Text(
                    _titles[_currentIndex],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                ),
                body: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ),
          ],
        ),
      );
    }

    // ── Narrow / Mobile layout ─────────────────────────────────────
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: _openDrawer,
        ),
        actions: [
          StreamBuilder<UserInfo?>(
            initialData: AuthService.instance.currentUser,
            stream: AuthService.instance.onUserChange,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withAlpha(30),
                  child: Text(
                    user.initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex < 4 ? _currentIndex : 4,
        onDestinationSelected: (i) {
          if (i == 4) {
            _openDrawer();
          } else {
            setState(() => _currentIndex = i);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF2563EB).withAlpha(25),
        height: 64,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Patients'),
          NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services_rounded), label: 'Doctors'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Appointments'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.menu_rounded), label: 'More'),
        ],
      ),
    );
  }

  // ── Shared drawer (mobile only) ──────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: StreamBuilder<UserInfo?>(
              initialData: AuthService.instance.currentUser,
              stream: AuthService.instance.onUserChange,
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withAlpha(30),
                      child: Text(
                        user?.initials ?? '?',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                      ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded),
                _drawerItem(1, 'Patients', Icons.people_outline, Icons.people_rounded),
                _drawerItem(2, 'Doctors', Icons.medical_services_outlined, Icons.medical_services_rounded),
                _drawerItem(3, 'Appointments', Icons.calendar_month_outlined, Icons.calendar_month_rounded),
                const Divider(),
                _drawerItem(4, 'Departments', Icons.business_outlined, Icons.business_rounded),
                _drawerItem(5, 'Medical Records', Icons.description_outlined, Icons.description_rounded),
                _drawerItem(6, 'Billing', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
                _drawerItem(7, 'Rooms', Icons.meeting_room_outlined, Icons.meeting_room_rounded),
                _drawerItem(8, 'Staff', Icons.badge_outlined, Icons.badge_rounded),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await AuthService.instance.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, String title, IconData iconOutlined, IconData iconFilled) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withAlpha(10) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(isSelected ? iconFilled : iconOutlined,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          Navigator.of(context).pop();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
