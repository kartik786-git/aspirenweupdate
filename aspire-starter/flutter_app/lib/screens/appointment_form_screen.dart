import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment;
  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endTimeCtrl = TextEditingController(text: '09:30');

  List<Patient> _patients = [];
  List<Doctor> _doctors = [];
  int? _patientId;
  int? _doctorId;
  DateTime _appointmentDate = DateTime.now();
  bool _saving = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    if (a != null) {
      _patientId = a.patientId;
      _doctorId = a.doctorId;
      _appointmentDate = a.appointmentDate;
      _startTimeCtrl.text = a.startTime;
      _endTimeCtrl.text = a.endTime;
      _reasonCtrl.text = a.reason ?? '';
    }
    _loadData();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getPatients(),
        ApiService.getDoctors(),
      ]);
      if (mounted) setState(() {
        _patients = results[0] as List<Patient>;
        _doctors = results[1] as List<Doctor>;
        _loadingData = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_patientId == null) { _showError('Please select a patient'); return; }
    if (_doctorId == null) { _showError('Please select a doctor'); return; }

    setState(() => _saving = true);
    try {
      final appt = Appointment(
        patientId: _patientId!,
        doctorId: _doctorId!,
        appointmentDate: _appointmentDate,
        startTime: _startTimeCtrl.text.trim(),
        endTime: _endTimeCtrl.text.trim(),
        reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      );
      await ApiService.createAppointment(appt);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patient & Doctor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _patientId,
                      decoration: _inputDecoration('Patient'),
                      items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                      onChanged: (v) => setState(() => _patientId = v),
                      validator: (v) => v == null ? 'Patient is required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _doctorId,
                      decoration: _inputDecoration('Doctor'),
                      items: _doctors.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.fullName} (${d.specialization})'))).toList(),
                      onChanged: (v) => setState(() => _doctorId = v),
                      validator: (v) => v == null ? 'Doctor is required' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text('Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _appointmentDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _appointmentDate = picked);
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration('Date', suffixIcon: Icons.calendar_today),
                        child: Text('${_appointmentDate.day}/${_appointmentDate.month}/${_appointmentDate.year}'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _field('Start Time', _startTimeCtrl, hint: '09:00')),
                        const SizedBox(width: 12),
                        Expanded(child: _field('End Time', _endTimeCtrl, hint: '09:30')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
                    const SizedBox(height: 12),
                    _field('Reason', _reasonCtrl, maxLines: 2),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDecoration(label, hint: hint),
      maxLines: maxLines,
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
