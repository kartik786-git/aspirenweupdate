import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/medical_record.dart';
import '../services/api_service.dart';

class MedicalRecordFormScreen extends StatefulWidget {
  final int patientId;
  const MedicalRecordFormScreen({super.key, required this.patientId});

  @override
  State<MedicalRecordFormScreen> createState() => _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _prescriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Doctor> _doctors = [];
  int? _doctorId;
  bool _saving = false;
  bool _loadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _treatmentCtrl.dispose();
    _prescriptionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await ApiService.getDoctors();
      if (mounted) setState(() { _doctors = doctors; _loadingDoctors = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_doctorId == null) { _showError('Please select a doctor'); return; }
    setState(() => _saving = true);

    try {
      final record = MedicalRecord(
        patientId: widget.patientId,
        doctorId: _doctorId!,
        diagnosis: _diagnosisCtrl.text.trim(),
        treatment: _treatmentCtrl.text.trim().isEmpty ? null : _treatmentCtrl.text.trim(),
        prescription: _prescriptionCtrl.text.trim().isEmpty ? null : _prescriptionCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ApiService.createMedicalRecord(record);
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
        title: const Text('Add Medical Record'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_loadingDoctors)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _doctorId,
                  decoration: InputDecoration(
                    labelText: 'Doctor',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
                  onChanged: (v) => setState(() => _doctorId = v),
                  validator: (v) => v == null ? 'Doctor is required' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisCtrl,
                decoration: InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Diagnosis is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _treatmentCtrl,
                decoration: InputDecoration(
                  labelText: 'Treatment Plan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prescriptionCtrl,
                decoration: InputDecoration(
                  labelText: 'Prescription',
                  hintText: 'Medication & dosage',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
