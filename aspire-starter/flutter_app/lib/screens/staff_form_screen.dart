import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/staff.dart';
import '../models/department.dart';
import '../services/api_service.dart';

class StaffFormScreen extends StatefulWidget {
  final Staff? staff;
  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  List<Department> _departments = [];
  String? _role;
  int? _departmentId;
  bool _isActive = true;
  bool _saving = false;
  bool _loadingDepts = true;
  bool get _isEdit => widget.staff != null;

  final _roles = ['Nurse', 'Receptionist', 'Technician', 'Pharmacist', 'Lab Assistant', 'Administrator'];

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    if (s != null) {
      _firstNameCtrl.text = s.firstName;
      _lastNameCtrl.text = s.lastName;
      _phoneCtrl.text = s.phone ?? '';
      _emailCtrl.text = s.email ?? '';
      _salaryCtrl.text = s.salary?.toStringAsFixed(2) ?? '';
      _role = s.role;
      _departmentId = s.departmentId;
      _isActive = s.isActive;
    }
    _loadDepartments();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _salaryCtrl.dispose();
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

    final staff = Staff(
      id: widget.staff?.id ?? 0,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      role: _role ?? '',
      departmentId: _departmentId ?? 0,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text.trim()),
      isActive: _isActive,
    );

    try {
      if (_isEdit) {
        await ApiService.updateStaff(widget.staff!.id, staff);
      } else {
        await ApiService.createStaff(staff);
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
        title: Text(_isEdit ? 'Edit Staff' : 'Add Staff'),
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
              const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field('First Name', _firstNameCtrl, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Last Name', _lastNameCtrl, required: true)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: _inputDecoration('Role'),
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _role = v),
                validator: (v) => v == null ? 'Role is required' : null,
              ),
              const SizedBox(height: 16),
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
              const Text('Contact & Salary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
              const SizedBox(height: 12),
              _field('Phone', _phoneCtrl),
              const SizedBox(height: 12),
              _field('Email', _emailCtrl),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryCtrl,
                decoration: _inputDecoration('Salary'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      decoration: _inputDecoration(label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
