class DashboardSummary {
  final String hospitalName;
  final int totalPatients;
  final int activeDoctors;
  final int todayAppointments;
  final int totalRooms;
  final int occupiedRooms;
  final double occupancyRate;
  final double monthlyRevenue;
  final int pendingBills;

  DashboardSummary({
    required this.hospitalName,
    required this.totalPatients,
    required this.activeDoctors,
    required this.todayAppointments,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.occupancyRate,
    required this.monthlyRevenue,
    required this.pendingBills,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      hospitalName: json['hospitalName'] as String? ?? 'HospiCare',
      totalPatients: json['totalPatients'] as int? ?? 0,
      activeDoctors: json['activeDoctors'] as int? ?? 0,
      todayAppointments: json['todayAppointments'] as int? ?? 0,
      totalRooms: json['totalRooms'] as int? ?? 0,
      occupiedRooms: json['occupiedRooms'] as int? ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingBills: json['pendingBills'] as int? ?? 0,
    );
  }
}
