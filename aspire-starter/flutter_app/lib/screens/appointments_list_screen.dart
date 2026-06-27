import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import 'appointment_form_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  List<Appointment> _appointments = [];
  bool _loading = true;
  String? _error;
  DateTime? _filterDate;
  String? _filterStatus;

  final _statuses = <String?>[null, 'Scheduled', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _filterDate = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final appointments = await ApiService.getAppointments(date: _filterDate, status: _filterStatus);
      if (mounted) setState(() { _appointments = appointments; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateStatus(Appointment a, String status) async {
    try {
      if (status == 'Cancelled') await ApiService.cancelAppointment(a.id);
      if (status == 'Completed') await ApiService.completeAppointment(a.id);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
  }

  void _openForm() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppointmentFormScreen()));
    _load();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Scheduled': return const Color(0xFF1A73E8);
      case 'Completed': return const Color(0xFF34A853);
      case 'Cancelled': return const Color(0xFFEA4335);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: const Color(0xFFF5F7FA),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _filterDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) { setState(() => _filterDate = picked); _load(); }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        _filterDate != null ? '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}' : 'All dates',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _filterStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontSize: 13))),
                      ..._statuses.where((s) => s != null).map((s) => DropdownMenuItem(value: s, child: Text(s!, style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (v) { setState(() => _filterStatus = v); _load(); },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null ? _buildError()
                : _appointments.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        onPressed: _openForm,
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
        Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No appointments found', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final a = _appointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(a.status).withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(a.status, style: TextStyle(color: _statusColor(a.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text('${a.startTime} - ${a.endTime}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF1A73E8)),
                      const SizedBox(width: 6),
                      Text(a.patient?.fullName ?? 'Patient #${a.patientId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.medical_services, size: 16, color: Color(0xFF34A853)),
                      const SizedBox(width: 6),
                      Text(a.doctor?.fullName ?? 'Doctor #${a.doctorId}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  if (a.reason != null && a.reason!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.description, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(a.reason!, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  if (a.status == 'Scheduled') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => _updateStatus(a, 'Cancelled'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF34A853)),
                          onPressed: () => _updateStatus(a, 'Completed'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
