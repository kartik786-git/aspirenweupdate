import 'doctor.dart';

class MedicalRecord {
  final int id;
  final int patientId;
  final int doctorId;
  final Doctor? doctor;
  final int? appointmentId;
  final String diagnosis;
  final String? treatment;
  final String? prescription;
  final String? notes;
  final DateTime recordDate;

  MedicalRecord({
    this.id = 0,
    required this.patientId,
    required this.doctorId,
    this.doctor,
    this.appointmentId,
    required this.diagnosis,
    this.treatment,
    this.prescription,
    this.notes,
    DateTime? recordDate,
  }) : recordDate = recordDate ?? DateTime.now();

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
    id: json['id'] as int? ?? 0,
    patientId: json['patientId'] as int? ?? 0,
    doctorId: json['doctorId'] as int? ?? 0,
    doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>) : null,
    appointmentId: json['appointmentId'] as int?,
    diagnosis: json['diagnosis'] as String? ?? '',
    treatment: json['treatment'] as String?,
    prescription: json['prescription'] as String?,
    notes: json['notes'] as String?,
    recordDate: json['recordDate'] != null ? DateTime.parse(json['recordDate'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'appointmentId': appointmentId,
    'diagnosis': diagnosis,
    'treatment': treatment,
    'prescription': prescription,
    'notes': notes,
  };
}
