import 'department.dart';
import 'patient.dart';

class Room {
  final int id;
  final String roomNumber;
  final String bedNumber;
  final String wardType;
  final int departmentId;
  final Department? department;
  final bool isOccupied;
  final int? currentPatientId;
  final Patient? currentPatient;
  final DateTime? admissionDate;
  final double dailyRate;
  final String? notes;

  Room({
    this.id = 0,
    required this.roomNumber,
    required this.bedNumber,
    this.wardType = 'General',
    this.departmentId = 0,
    this.department,
    this.isOccupied = false,
    this.currentPatientId,
    this.currentPatient,
    this.admissionDate,
    this.dailyRate = 0,
    this.notes,
  });

  String get displayName => 'Room $roomNumber - Bed $bedNumber ($wardType)';

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'] as int? ?? 0,
    roomNumber: json['roomNumber'] as String? ?? '',
    bedNumber: json['bedNumber'] as String? ?? '',
    wardType: json['wardType'] as String? ?? 'General',
    departmentId: json['departmentId'] as int? ?? 0,
    department: json['department'] != null ? Department.fromJson(json['department'] as Map<String, dynamic>) : null,
    isOccupied: json['isOccupied'] as bool? ?? false,
    currentPatientId: json['currentPatientId'] as int?,
    currentPatient: json['currentPatient'] != null ? Patient.fromJson(json['currentPatient'] as Map<String, dynamic>) : null,
    admissionDate: json['admissionDate'] != null ? DateTime.parse(json['admissionDate'] as String) : null,
    dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0,
    notes: json['notes'] as String?,
  );
}
