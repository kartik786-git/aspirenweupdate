import 'package:flutter/material.dart';
import '../models/department.dart';
import '../services/api_service.dart';
import 'department_form_screen.dart';

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({super.key});

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen> {
  List<Department> _departments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final depts = await ApiService.getDepartments();
      if (mounted) setState(() { _departments = depts; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _openForm([Department? dept]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DepartmentFormScreen(department: dept)));
    _load();
  }

  IconData _deptIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('emergency') || n.contains('er')) return Icons.local_hospital;
    if (n.contains('cardio')) return Icons.favorite;
    if (n.contains('neuro')) return Icons.psychology;
    if (n.contains('pediatric') || n.contains('child')) return Icons.child_care;
    if (n.contains('ortho')) return Icons.accessibility_new;
    if (n.contains('dental') || n.contains('dent')) return Icons.health_and_safety;
    if (n.contains('eye') || n.contains('opthal')) return Icons.visibility;
    if (n.contains('ent') || n.contains('ear')) return Icons.hearing;
    if (n.contains('derma') || n.contains('skin')) return Icons.auto_fix_high;
    if (n.contains('radio') || n.contains('xray')) return Icons.radio;
    if (n.contains('surgery') || n.contains('surg')) return Icons.content_cut;
    if (n.contains('maternity') || n.contains('obste')) return Icons.pregnant_woman;
    if (n.contains('psych')) return Icons.psychology;
    return Icons.business;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null ? _buildError()
          : _departments.isEmpty ? _buildEmpty()
          : _buildList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.business_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No departments found', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final d = _departments[index];
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_deptIcon(d.name), color: const Color(0xFF1A73E8), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          if (d.description != null && d.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(d.description!, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                          if (d.location != null && d.location!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(d.location!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
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
