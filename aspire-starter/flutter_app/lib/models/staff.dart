import 'department.dart';

class Staff {
  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final int departmentId;
  final Department? department;
  final String? phone;
  final String? email;
  final DateTime hireDate;
  final double? salary;
  final bool isActive;

  Staff({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    this.role = '',
    this.departmentId = 0,
    this.department,
    this.phone,
    this.email,
    DateTime? hireDate,
    this.salary,
    this.isActive = true,
  }) : hireDate = hireDate ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id'] as int? ?? 0,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    role: json['role'] as String? ?? '',
    departmentId: json['departmentId'] as int? ?? 0,
    department: json['department'] != null ? Department.fromJson(json['department'] as Map<String, dynamic>) : null,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    hireDate: json['hireDate'] != null ? DateTime.parse(json['hireDate'] as String) : DateTime.now(),
    salary: (json['salary'] as num?)?.toDouble(),
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'departmentId': departmentId,
    'phone': phone,
    'email': email,
    'salary': salary,
    'isActive': isActive,
  };
}
