import 'department.dart';

class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String specialization;
  final int departmentId;
  final Department? department;
  final String? phone;
  final String? email;
  final String? qualification;
  final int experienceYears;
  final String? schedule;
  final bool isActive;

  Doctor({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    this.specialization = '',
    this.departmentId = 0,
    this.department,
    this.phone,
    this.email,
    this.qualification,
    this.experienceYears = 0,
    this.schedule,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] as int? ?? 0,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    specialization: json['specialization'] as String? ?? '',
    departmentId: json['departmentId'] as int? ?? 0,
    department: json['department'] != null ? Department.fromJson(json['department'] as Map<String, dynamic>) : null,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    qualification: json['qualification'] as String?,
    experienceYears: json['experienceYears'] as int? ?? 0,
    schedule: json['schedule'] as String?,
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'specialization': specialization,
    'departmentId': departmentId,
    'phone': phone,
    'email': email,
    'qualification': qualification,
    'experienceYears': experienceYears,
    'schedule': schedule,
    'isActive': isActive,
  };
}
