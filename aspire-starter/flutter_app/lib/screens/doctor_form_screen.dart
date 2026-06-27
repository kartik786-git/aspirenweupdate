import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/department.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';

class DoctorFormScreen extends StatefulWidget {
  final Doctor? doctor;
  const DoctorFormScreen({super.key, this.doctor});

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController(text: '0');

  List<Department> _departments = [];
  int? _departmentId;
  bool _isActive = true;
  bool _saving = false;
  bool _loadingDepts = true;
  bool get _isEdit => widget.doctor != null;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    if (d != null) {
      _firstNameCtrl.text = d.firstName;
      _lastNameCtrl.text = d.lastName;
      _specializationCtrl.text = d.specialization;
      _phoneCtrl.text = d.phone ?? '';
      _emailCtrl.text = d.email ?? '';
      _qualificationCtrl.text = d.qualification ?? '';
      _scheduleCtrl.text = d.schedule ?? '';
      _experienceCtrl.text = d.experienceYears.toString();
      _departmentId = d.departmentId;
      _isActive = d.isActive;
    }
    _loadDepartments();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _specializationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _qualificationCtrl.dispose();
    _scheduleCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await ApiService.getDepartments();
      if (mounted) setState(() { _departments = depts; _loadingDepts = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDepts = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final doctor = Doctor(
      id: widget.doctor?.id ?? 0,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      specialization: _specializationCtrl.text.trim(),
      departmentId: _departmentId ?? 0,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      qualification: _qualificationCtrl.text.trim().isEmpty ? null : _qualificationCtrl.text.trim(),
      experienceYears: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
      schedule: _scheduleCtrl.text.trim().isEmpty ? null : _scheduleCtrl.text.trim(),
      isActive: _isActive,
    );

    try {
      if (_isEdit) {
        await ApiService.updateDoctor(widget.doctor!.id, doctor);
      } else {
        await ApiService.createDoctor(doctor);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Doctor' : 'Add Doctor'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Personal Information'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field('First Name', _firstNameCtrl, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Last Name', _lastNameCtrl, required: true)),
                ],
              ),
              const SizedBox(height: 12),
              _field('Specialization', _specializationCtrl, required: true),
              const SizedBox(height: 12),
              if (_loadingDepts)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _departmentId != null && _departments.any((d) => d.id == _departmentId) ? _departmentId : null,
                  decoration: _inputDecoration('Department'),
                  items: _departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                  onChanged: (v) => setState(() => _departmentId = v),
                ),
              const SizedBox(height: 20),
              _section('Contact & Qualifications'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field('Phone', _phoneCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Email', _emailCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              _field('Qualification', _qualificationCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceCtrl,
                      decoration: _inputDecoration('Experience (years)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field('Schedule', _scheduleCtrl, hint: 'e.g. Mon-Fri 9AM-5PM'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)));
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, String? hint}) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDecoration(label, hint: hint),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
