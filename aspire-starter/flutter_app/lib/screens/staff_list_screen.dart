import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/api_service.dart';
import 'staff_form_screen.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<Staff> _staff = [];
  bool _loading = true;
  String? _error;
  String? _filterRole;

  final _roles = ['Nurse', 'Receptionist', 'Technician', 'Pharmacist', 'Lab Assistant', 'Administrator'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final staff = await ApiService.getStaff();
      if (mounted) {
        var filtered = staff;
        if (_filterRole != null) {
          filtered = staff.where((s) => s.role == _filterRole).toList();
        }
        setState(() { _staff = filtered; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Staff s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Staff'),
        content: Text('Deactivate ${s.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirm == true) {
      try { await ApiService.deleteStaff(s.id); await _load(); }
      catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); }
    }
  }

  void _openForm([Staff? staff]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => StaffFormScreen(staff: staff)));
    _load();
  }

  IconData _roleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'nurse': return Icons.medical_services;
      case 'receptionist': return Icons.support_agent;
      case 'technician': return Icons.handyman;
      case 'pharmacist': return Icons.medication;
      case 'lab assistant': return Icons.science;
      case 'administrator': return Icons.admin_panel_settings;
      default: return Icons.badge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 44,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('All', null),
                ..._roles.map((r) => _filterChip(r, r)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null ? _buildError()
                : _staff.isEmpty ? _buildEmpty()
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

  Widget _filterChip(String label, String? role) {
    final selected = _filterRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
        selected: selected,
        selectedColor: const Color(0xFF1A73E8),
        checkmarkColor: Colors.white,
        onSelected: (_) { setState(() => _filterRole = role); _load(); },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
        FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.badge_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No staff found', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _staff.length,
        itemBuilder: (context, index) {
          final s = _staff[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openForm(s),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF00ACC1).withAlpha(25),
                      child: Icon(_roleIcon(s.role), color: const Color(0xFF00ACC1), size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00ACC1).withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s.role, style: const TextStyle(color: Color(0xFF00ACC1), fontSize: 12)),
                              ),
                              if (s.department != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.business, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(s.department!.name, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ],
                          ),
                          if (s.email != null || s.phone != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (s.email != null) ...[
                                  Icon(Icons.email, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(s.email!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                                if (s.email != null && s.phone != null) const SizedBox(width: 12),
                                if (s.phone != null) ...[
                                  Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(s.phone!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!s.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text('Inactive', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(s);
                        if (v == 'delete') _delete(s);
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
