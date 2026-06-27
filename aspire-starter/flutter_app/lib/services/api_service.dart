import 'dart:convert';
import 'dart:io' show HttpException, Platform;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart' as http;
import '../models/dashboard_summary.dart';
import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/department.dart';
import '../models/medical_record.dart';
import '../models/billing.dart';
import '../models/room.dart';
import '../models/staff.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    if (!kIsWeb) {
      final customUrl = Platform.environment['API_BASE_URL'];
      if (customUrl != null && customUrl.isNotEmpty) return customUrl;
    }
    if (!kIsWeb) {
      final aspireUrl = Platform.environment['services__apiservice__http__0'];
      if (aspireUrl != null && aspireUrl.isNotEmpty) return aspireUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5520';
    return 'http://localhost:5520';
  }

  static Future<Map<String, String>?> _authHeaders() async {
    final token = await AuthService.instance.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static const _timeout = Duration(seconds: 15);

  static Future<Map<String, String>> _headersOrThrow() async {
    final h = await _authHeaders();
    if (h == null) throw HttpException('Not authenticated');
    return h;
  }

  // ── Dashboard ──
  static Future<DashboardSummary> fetchSummary() async {
    final uri = Uri.parse('$baseUrl/api/mobile/summary');
    final headers = await _headersOrThrow();
    final response = await http.get(uri, headers: headers).timeout(_timeout);
    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw HttpException('Failed to load summary: ${response.statusCode}');
  }

  // ── Patients ──
  static Future<List<Patient>> getPatients({String? query}) async {
    final uri = Uri.parse('$baseUrl/api/patients${query != null ? '/search?q=${Uri.encodeQueryComponent(query)}' : ''}');
    final h = await _headersOrThrow();
    final r = await http.get(uri, headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load patients');
  }

  static Future<Patient> getPatient(int id) async {
    final uri = Uri.parse('$baseUrl/api/patients/$id');
    final h = await _headersOrThrow();
    final r = await http.get(uri, headers: h).timeout(_timeout);
    if (r.statusCode == 200) return Patient.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Patient not found');
  }

  static Future<Patient> createPatient(Patient p) async {
    final uri = Uri.parse('$baseUrl/api/patients');
    final h = await _headersOrThrow();
    final r = await http.post(uri, headers: h, body: jsonEncode(p.toJson())).timeout(_timeout);
    if (r.statusCode == 201) return Patient.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to create patient: ${r.statusCode}');
  }

  static Future<Patient> updatePatient(int id, Patient p) async {
    final uri = Uri.parse('$baseUrl/api/patients/$id');
    final h = await _headersOrThrow();
    final r = await http.put(uri, headers: h, body: jsonEncode(p.toJson())).timeout(_timeout);
    if (r.statusCode == 200) return Patient.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to update patient');
  }

  static Future<void> deletePatient(int id) async {
    final uri = Uri.parse('$baseUrl/api/patients/$id');
    final h = await _headersOrThrow();
    await http.delete(uri, headers: h).timeout(_timeout);
  }

  // ── Doctors ──
  static Future<List<Doctor>> getDoctors({int? departmentId}) async {
    var path = '$baseUrl/api/doctors';
    if (departmentId != null) path = '$baseUrl/api/doctors/department/$departmentId';
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse(path), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load doctors');
  }

  static Future<Doctor> getDoctor(int id) async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/doctors/$id'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) return Doctor.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Doctor not found');
  }

  static Future<Doctor> createDoctor(Doctor d) async {
    final h = await _headersOrThrow();
    final r = await http.post(Uri.parse('$baseUrl/api/doctors'), headers: h, body: jsonEncode(d.toJson())).timeout(_timeout);
    if (r.statusCode == 201) return Doctor.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to create doctor');
  }

  static Future<Doctor> updateDoctor(int id, Doctor d) async {
    final h = await _headersOrThrow();
    final r = await http.put(Uri.parse('$baseUrl/api/doctors/$id'), headers: h, body: jsonEncode(d.toJson())).timeout(_timeout);
    if (r.statusCode == 200) return Doctor.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to update doctor');
  }

  static Future<void> deleteDoctor(int id) async {
    final h = await _headersOrThrow();
    await http.delete(Uri.parse('$baseUrl/api/doctors/$id'), headers: h).timeout(_timeout);
  }

  // ── Appointments ──
  static Future<List<Appointment>> getAppointments({DateTime? date, String? status}) async {
    var params = <String, String>{};
    if (date != null) params['date'] = date.toIso8601String().substring(0, 10);
    if (status != null) params['status'] = status;
    final qs = params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    final uri = Uri.parse('$baseUrl/api/appointments${qs.isNotEmpty ? '?$qs' : ''}');
    final h = await _headersOrThrow();
    final r = await http.get(uri, headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load appointments');
  }

  static Future<Appointment> getAppointment(int id) async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/appointments/$id'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) return Appointment.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Appointment not found');
  }

  static Future<Appointment> createAppointment(Appointment a) async {
    final h = await _headersOrThrow();
    final body = a.toJson();
    body['appointmentDate'] = a.appointmentDate.toIso8601String().substring(0, 10);
    final r = await http.post(Uri.parse('$baseUrl/api/appointments'), headers: h, body: jsonEncode(body)).timeout(_timeout);
    if (r.statusCode == 201) return Appointment.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    final err = jsonDecode(r.body);
    throw HttpException(err['message'] as String? ?? 'Failed to create appointment');
  }

  static Future<void> cancelAppointment(int id) async {
    final h = await _headersOrThrow();
    await http.put(Uri.parse('$baseUrl/api/appointments/$id/cancel'), headers: h).timeout(_timeout);
  }

  static Future<void> completeAppointment(int id) async {
    final h = await _headersOrThrow();
    await http.put(Uri.parse('$baseUrl/api/appointments/$id/complete'), headers: h).timeout(_timeout);
  }

  // ── Departments ──
  static Future<List<Department>> getDepartments() async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/departments'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load departments');
  }

  static Future<Department> getDepartment(int id) async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/departments/$id'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) return Department.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Department not found');
  }

  static Future<Department> createDepartment(Department d) async {
    final h = await _headersOrThrow();
    final r = await http.post(Uri.parse('$baseUrl/api/departments'), headers: h, body: jsonEncode(d.toJson())).timeout(_timeout);
    if (r.statusCode == 201) return Department.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to create department');
  }

  static Future<Department> updateDepartment(int id, Department d) async {
    final h = await _headersOrThrow();
    final r = await http.put(Uri.parse('$baseUrl/api/departments/$id'), headers: h, body: jsonEncode(d.toJson())).timeout(_timeout);
    if (r.statusCode == 200) return Department.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to update department');
  }

  // ── Medical Records ──
  static Future<List<MedicalRecord>> getMedicalRecords(int patientId) async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/medical-records/patient/$patientId'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load records');
  }

  static Future<MedicalRecord> createMedicalRecord(MedicalRecord mr) async {
    final h = await _headersOrThrow();
    final r = await http.post(Uri.parse('$baseUrl/api/medical-records'), headers: h, body: jsonEncode(mr.toJson())).timeout(_timeout);
    if (r.statusCode == 201) return MedicalRecord.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to create medical record');
  }

  // ── Billing ──
  static Future<List<Billing>> getBillings({int? patientId}) async {
    var path = '$baseUrl/api/billing';
    if (patientId != null) path = '$baseUrl/api/billing/patient/$patientId';
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse(path), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Billing.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load bills');
  }

  static Future<void> markBillPaid(int id, String method, {double amount = 0}) async {
    final h = await _headersOrThrow();
    final uri = Uri.parse('$baseUrl/api/billing/$id/pay?amount=${amount.toStringAsFixed(2)}');
    await http.put(uri, headers: h).timeout(_timeout);
  }

  // ── Rooms ──
  static Future<List<Room>> getRooms() async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/rooms'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load rooms');
  }

  static Future<void> admitPatient(int roomId, int patientId) async {
    final h = await _headersOrThrow();
    await http.put(Uri.parse('$baseUrl/api/rooms/$roomId/assign?patientId=$patientId'), headers: h).timeout(_timeout);
  }

  static Future<void> dischargePatient(int roomId) async {
    final h = await _headersOrThrow();
    await http.put(Uri.parse('$baseUrl/api/rooms/$roomId/discharge'), headers: h).timeout(_timeout);
  }

  // ── Staff ──
  static Future<List<Staff>> getStaff() async {
    final h = await _headersOrThrow();
    final r = await http.get(Uri.parse('$baseUrl/api/staff'), headers: h).timeout(_timeout);
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Staff.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to load staff');
  }

  static Future<Staff> createStaff(Staff s) async {
    final h = await _headersOrThrow();
    final r = await http.post(Uri.parse('$baseUrl/api/staff'), headers: h, body: jsonEncode(s.toJson())).timeout(_timeout);
    if (r.statusCode == 201) return Staff.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to create staff');
  }

  static Future<Staff> updateStaff(int id, Staff s) async {
    final h = await _headersOrThrow();
    final r = await http.put(Uri.parse('$baseUrl/api/staff/$id'), headers: h, body: jsonEncode(s.toJson())).timeout(_timeout);
    if (r.statusCode == 200) return Staff.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw HttpException('Failed to update staff');
  }

  static Future<void> deleteStaff(int id) async {
    final h = await _headersOrThrow();
    await http.delete(Uri.parse('$baseUrl/api/staff/$id'), headers: h).timeout(_timeout);
  }
}
