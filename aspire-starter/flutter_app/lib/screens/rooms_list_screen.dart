import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  List<Room> _rooms = [];
  List<Patient> _patients = [];
  bool _loading = true;
  String? _error;
  String? _filterWard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getRooms(),
        ApiService.getPatients(),
      ]);
      if (mounted) setState(() {
        _rooms = results[0] as List<Room>;
        _patients = results[1] as List<Patient>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _admitPatient(Room room) async {
    final patient = await showDialog<Patient>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Patient to Admit'),
        children: _patients.where((p) => p.isActive).map((p) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, p),
          child: ListTile(
            leading: CircleAvatar(child: Text('${p.firstName[0]}${p.lastName[0]}'.toUpperCase())),
            title: Text(p.fullName),
            subtitle: Text(p.phone),
            contentPadding: EdgeInsets.zero,
          ),
        )).toList(),
      ),
    );

    if (patient != null) {
      try {
        await ApiService.admitPatient(room.id, patient.id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${patient.fullName} admitted to ${room.displayName}'), backgroundColor: const Color(0xFF34A853)),
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _dischargePatient(Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discharge Patient'),
        content: Text('Discharge ${room.currentPatient?.fullName ?? 'patient'} from ${room.displayName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discharge')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.dischargePatient(room.id);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room ${room.roomNumber} discharged'), backgroundColor: const Color(0xFFFBBC04)),
          );
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardTypes = _rooms.map((r) => r.wardType).toSet().toList();
    return Scaffold(
      body: Column(
        children: [
          if (wardTypes.isNotEmpty)
            Container(
              height: 44,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', null),
                  ...wardTypes.map((w) => _filterChip(w, w)),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null ? _buildError()
                : _rooms.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? ward) {
    final selected = _filterWard == ward;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
        selected: selected,
        selectedColor: const Color(0xFF1A73E8),
        checkmarkColor: Colors.white,
        onSelected: (_) { setState(() => _filterWard = ward); },
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
        Icon(Icons.meeting_room_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No rooms configured', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildList() {
    final filtered = _filterWard != null ? _rooms.where((r) => r.wardType == _filterWard).toList() : _rooms;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final r = filtered[index];
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: r.isOccupied
                              ? const Color(0xFFEA4335).withAlpha(15)
                              : const Color(0xFF34A853).withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          r.isOccupied ? Icons.person : Icons.accessible,
                          color: r.isOccupied ? const Color(0xFFEA4335) : const Color(0xFF34A853),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (r.department != null)
                              Text(r.department!.name, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.isOccupied ? const Color(0xFFEA4335).withAlpha(15) : const Color(0xFF34A853).withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.isOccupied ? 'Occupied' : 'Available',
                          style: TextStyle(
                            color: r.isOccupied ? const Color(0xFFEA4335) : const Color(0xFF34A853),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (r.isOccupied && r.currentPatient != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Color(0xFF1A73E8)),
                        const SizedBox(width: 6),
                        Text(r.currentPatient!.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (r.admissionDate != null)
                          Text('Since ${r.admissionDate!.day}/${r.admissionDate!.month}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Daily rate: \$${r.dailyRate.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!r.isOccupied)
                        FilledButton.icon(
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Admit', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF34A853)),
                          onPressed: () => _admitPatient(r),
                        ),
                      if (r.isOccupied)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.exit_to_app, size: 16),
                          label: const Text('Discharge', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEA4335)),
                          onPressed: () => _dischargePatient(r),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
