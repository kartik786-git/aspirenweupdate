import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/department.dart';
import '../services/api_service.dart';
import 'doctor_form_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  List<Doctor> _doctors = [];
  List<Department> _departments = [];
  bool _loading = true;
  String? _error;
  int? _filterDeptId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getDoctors(departmentId: _filterDeptId),
        ApiService.getDepartments(),
      ]);
      if (mounted) setState(() { _doctors = results[0] as List<Doctor>; _departments = results[1] as List<Department>; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Doctor d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Doctor'),
        content: Text('Deactivate ${d.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirm == true) {
      try { await ApiService.deleteDoctor(d.id); await _load(); }
      catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); }
    }
  }

  void _openForm([Doctor? doctor]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DoctorFormScreen(doctor: doctor)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_departments.isNotEmpty)
            Container(
              height: 44,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', null),
                  ..._departments.map((d) => _filterChip(d.name, d.id)),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null ? _buildError()
                : _doctors.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, int? deptId) {
    final selected = _filterDeptId == deptId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
        selected: selected,
        selectedColor: const Color(0xFF1A73E8),
        checkmarkColor: Colors.white,
        onSelected: (_) { setState(() => _filterDeptId = deptId); _load(); },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No doctors found', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          final d = _doctors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openForm(d),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.withAlpha(25),
                      child: Text(d.initials, style: const TextStyle(color: Color(0xFF34A853), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(d.specialization, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          if (d.department != null)
                            Text(d.department!.name, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFFBBC04)),
                              const SizedBox(width: 4),
                              Text('${d.experienceYears} yrs', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              if (d.phone != null) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(d.phone!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!d.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text('Inactive', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(d);
                        if (v == 'delete') _delete(d);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Deactivate', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension on Doctor {
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
