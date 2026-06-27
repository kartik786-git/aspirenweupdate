import 'patient.dart';

class Billing {
  final int id;
  final int patientId;
  final Patient? patient;
  final int? appointmentId;
  final String invoiceNumber;
  final DateTime billDate;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String? paymentMethod;
  final String? remarks;

  Billing({
    this.id = 0,
    required this.patientId,
    this.patient,
    this.appointmentId,
    required this.invoiceNumber,
    DateTime? billDate,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.status = 'Unpaid',
    this.paymentMethod,
    this.remarks,
  }) : billDate = billDate ?? DateTime.now();

  double get dueAmount => totalAmount - paidAmount;

  factory Billing.fromJson(Map<String, dynamic> json) => Billing(
    id: json['id'] as int? ?? 0,
    patientId: json['patientId'] as int? ?? 0,
    patient: json['patient'] != null ? Patient.fromJson(json['patient'] as Map<String, dynamic>) : null,
    appointmentId: json['appointmentId'] as int?,
    invoiceNumber: json['invoiceNumber'] as String? ?? '',
    billDate: json['billDate'] != null ? DateTime.parse(json['billDate'] as String) : DateTime.now(),
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'Unpaid',
    paymentMethod: json['paymentMethod'] as String?,
    remarks: json['remarks'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'appointmentId': appointmentId,
    'invoiceNumber': invoiceNumber,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'status': status,
    'paymentMethod': paymentMethod,
    'remarks': remarks,
  };
}
