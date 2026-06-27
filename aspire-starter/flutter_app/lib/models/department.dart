class Department {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final int? headDoctorId;
  final DateTime createdAt;

  Department({
    this.id = 0,
    required this.name,
    this.description,
    this.location,
    this.headDoctorId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    location: json['location'] as String?,
    headDoctorId: json['headDoctorId'] as int?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    'name': name,
    'description': description,
    'location': location,
    'headDoctorId': headDoctorId,
  };
}
