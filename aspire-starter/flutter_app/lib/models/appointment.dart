import 'patient.dart';
import 'doctor.dart';

class Appointment {
  final int id;
  final int patientId;
  final Patient? patient;
  final int doctorId;
  final Doctor? doctor;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    this.id = 0,
    required this.patientId,
    this.patient,
    required this.doctorId,
    this.doctor,
    required this.appointmentDate,
    this.startTime = '09:00',
    this.endTime = '09:30',
    this.status = 'Scheduled',
    this.reason,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] as int? ?? 0,
    patientId: json['patientId'] as int? ?? 0,
    patient: json['patient'] != null ? Patient.fromJson(json['patient'] as Map<String, dynamic>) : null,
    doctorId: json['doctorId'] as int? ?? 0,
    doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>) : null,
    appointmentDate: DateTime.parse(json['appointmentDate'] as String),
    startTime: json['startTime'] as String? ?? '09:00',
    endTime: json['endTime'] as String? ?? '09:30',
    status: json['status'] as String? ?? 'Scheduled',
    reason: json['reason'] as String?,
    notes: json['notes'] as String?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'appointmentDate': appointmentDate.toIso8601String().substring(0, 10),
    'startTime': startTime,
    'endTime': endTime,
    'reason': reason,
  };
}
