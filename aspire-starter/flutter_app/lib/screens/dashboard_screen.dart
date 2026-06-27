import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final bool embedded;
  final ValueChanged<int>? onNavigate;
  const DashboardScreen({super.key, this.embedded = true, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Future<DashboardSummary> _summaryFuture;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.fetchSummary();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _animCtrl.reset();
    setState(() => _summaryFuture = ApiService.fetchSummary());
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<DashboardSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2563EB)),
                  SizedBox(height: 16),
                  Text('Loading hospital data...',
                      style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.cloud_off_rounded,
                          size: 56, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Could not connect to server',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final s = snapshot.data!;
          final isWide = MediaQuery.of(context).size.width > 900;

          return FadeTransition(
            opacity: _fadeIn,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isWide ? 32 : 16),
              children: [
                // ── Hero header ──────────────────────────────────
                Container(
                  padding: EdgeInsets.all(isWide ? 32 : 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.local_hospital_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.hospitalName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(160),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isWide ? 28 : 20),

                // ── Stats grid ───────────────────────────────────
                isWide
                    ? Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          SizedBox(
                            width: 220,
                            child: _statCard('Total Patients',
                                '${s.totalPatients}', Icons.people_rounded,
                                const Color(0xFF2563EB), 'Active records'),
                          ),
                          SizedBox(
                            width: 220,
                            child: _statCard('Active Doctors',
                                '${s.activeDoctors}',
                                Icons.medical_services_rounded,
                                const Color(0xFF059669), 'On staff'),
                          ),
                          SizedBox(
                            width: 220,
                            child: _statCard("Today's Appointments",
                                '${s.todayAppointments}',
                                Icons.calendar_month_rounded,
                                const Color(0xFFD97706), 'Scheduled'),
                          ),
                          SizedBox(
                            width: 220,
                            child: _statCard('Pending Bills',
                                '${s.pendingBills}',
                                Icons.receipt_long_rounded,
                                const Color(0xFFDC2626), 'Unpaid'),
                          ),
                          SizedBox(
                            width: 220,
                            child: _statCard('Room Occupancy',
                                '${s.occupiedRooms}/${s.totalRooms}',
                                Icons.meeting_room_rounded,
                                const Color(0xFF7C3AED),
                                '${s.occupancyRate.toStringAsFixed(1)}% occupied'),
                          ),
                          SizedBox(
                            width: 220,
                            child: _statCard('Monthly Revenue',
                                '\$${s.monthlyRevenue.toStringAsFixed(0)}',
                                Icons.trending_up_rounded,
                                const Color(0xFF0891B2), 'This month'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: _statCard('Total Patients',
                                      '${s.totalPatients}', Icons.people_rounded,
                                      const Color(0xFF2563EB))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _statCard('Active Doctors',
                                      '${s.activeDoctors}',
                                      Icons.medical_services_rounded,
                                      const Color(0xFF059669))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                  child: _statCard("Today's Appointments",
                                      '${s.todayAppointments}',
                                      Icons.calendar_month_rounded,
                                      const Color(0xFFD97706))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _statCard('Pending Bills',
                                      '${s.pendingBills}',
                                      Icons.receipt_long_rounded,
                                      const Color(0xFFDC2626))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                  child: _statCard('Room Occupancy',
                                      '${s.occupiedRooms}/${s.totalRooms}',
                                      Icons.meeting_room_rounded,
                                      const Color(0xFF7C3AED),
                                      '${s.occupancyRate.toStringAsFixed(1)}%')),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _statCard('Monthly Revenue',
                                      '\$${s.monthlyRevenue.toStringAsFixed(0)}',
                                      Icons.trending_up_rounded,
                                      const Color(0xFF0891B2))),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: isWide ? 28 : 24),

                // ── Bottom section: Occupancy bar + Quick actions ──
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _occupancyCard(s),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _quickActionsCard(),
                      ),
                    ],
                  )
                else ...[
                  _occupancyCard(s),
                  const SizedBox(height: 16),
                  _quickActionsCard(),
                ],
                SizedBox(height: isWide ? 24 : 16),
              ],
            ),
          );
        },
      ),
    );

    if (widget.embedded) {
      return Scaffold(backgroundColor: const Color(0xFFF8FAFC), body: body);
    }
    return body;
  }

  Widget _statCard(String title, String value, IconData icon, Color color,
      [String? subtitle]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (subtitle != null)
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _occupancyCard(DashboardSummary s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.meeting_room_rounded,
                    color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Bed Occupancy',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${s.occupancyRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.occupancyRate / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${s.occupiedRooms} occupied',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Text('${s.totalRooms} total',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Quick Actions',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _quickActionBtn('Register Patient', Icons.person_add_rounded,
              const Color(0xFF2563EB), 1), // switch to Patients tab
          const SizedBox(height: 10),
          _quickActionBtn('Book Appointment', Icons.calendar_month_rounded,
              const Color(0xFF059669), 3), // switch to Appointments tab
          const SizedBox(height: 10),
          _quickActionBtn('View All Patients', Icons.people_rounded,
              const Color(0xFFD97706), 1),
        ],
      ),
    );
  }

  Widget _quickActionBtn(
      String label, IconData icon, Color color, int targetIndex) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _navigateTo(targetIndex),
        icon: Icon(icon, size: 18, color: color),
        label: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withAlpha(60)),
          backgroundColor: color.withAlpha(8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _navigateTo(int targetIndex) {
    widget.onNavigate?.call(targetIndex);
  }
}
