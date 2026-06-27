import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import 'patient_form_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  List<Patient> _patients = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String? query}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final patients = await ApiService.getPatients(query: query);
      if (mounted) setState(() { _patients = patients; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Patient p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Patient'),
        content: Text('Archive ${p.fullName}? They will be marked inactive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Archive')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deletePatient(p.id);
        await _load(query: _searchController.text.isNotEmpty ? _searchController.text : null);
      } catch (e) {
        if (mounted) _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _openForm([Patient? patient]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PatientFormScreen(patient: patient)),
    );
    _load(query: _searchController.text.isNotEmpty ? _searchController.text : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _showSearch = false);
                      _load();
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) => _load(query: q.isNotEmpty ? q : null),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _patients.isEmpty
                        ? _buildEmpty()
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Could not load patients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _load(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No patients found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Tap + to register a new patient', style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => _load(query: _searchController.text.isNotEmpty ? _searchController.text : null),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final p = _patients[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openForm(p),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF1A73E8).withAlpha(25),
                      child: Text(
                        p.initials,
                        style: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(p.phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              if (p.gender != null) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.person, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(p.gender!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ],
                          ),
                          if (p.email != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.email, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(p.email!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!p.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Inactive', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(p);
                        if (v == 'delete') _delete(p);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Archive', style: TextStyle(color: Colors.red))),
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

extension on Patient {
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
