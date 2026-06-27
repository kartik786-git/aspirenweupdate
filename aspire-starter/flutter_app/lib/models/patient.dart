class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String phone;
  final String? email;
  final String? address;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime registrationDate;
  final bool isActive;

  Patient({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    required this.phone,
    this.email,
    this.address,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactPhone,
    DateTime? registrationDate,
    this.isActive = true,
  }) : registrationDate = registrationDate ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'] as int? ?? 0,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
    gender: json['gender'] as String?,
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String?,
    address: json['address'] as String?,
    bloodGroup: json['bloodGroup'] as String?,
    emergencyContactName: json['emergencyContactName'] as String?,
    emergencyContactPhone: json['emergencyContactPhone'] as String?,
    registrationDate: json['registrationDate'] != null ? DateTime.parse(json['registrationDate'] as String) : DateTime.now(),
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'phone': phone,
    'email': email,
    'address': address,
    'bloodGroup': bloodGroup,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'isActive': isActive,
  };
}
