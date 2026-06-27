import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/medical_record.dart';
import '../services/api_service.dart';
import 'medical_record_form_screen.dart';

class MedicalRecordsListScreen extends StatefulWidget {
  const MedicalRecordsListScreen({super.key});

  @override
  State<MedicalRecordsListScreen> createState() => _MedicalRecordsListScreenState();
}

class _MedicalRecordsListScreenState extends State<MedicalRecordsListScreen> {
  List<Patient> _patients = [];
  List<MedicalRecord> _records = [];
  int? _selectedPatientId;
  bool _loadingPatients = true;
  bool _loadingRecords = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await ApiService.getPatients();
      if (mounted) setState(() { _patients = patients; _loadingPatients = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingPatients = false; });
    }
  }

  Future<void> _loadRecords(int patientId) async {
    setState(() { _loadingRecords = true; _error = null; _selectedPatientId = patientId; });
    try {
      final records = await ApiService.getMedicalRecords(patientId);
      if (mounted) setState(() { _records = records; _loadingRecords = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingRecords = false; });
    }
  }

  void _openForm() async {
    if (_selectedPatientId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MedicalRecordFormScreen(patientId: _selectedPatientId!)),
    );
    _loadRecords(_selectedPatientId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_loadingPatients)
            const LinearProgressIndicator()
          else
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<int>(
                value: _selectedPatientId,
                decoration: InputDecoration(
                  labelText: 'Select Patient',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                onChanged: (v) { if (v != null) _loadRecords(v); },
              ),
            ),
          Expanded(
            child: _error != null ? _buildError()
                : _selectedPatientId == null ? _buildSelectPatient()
                : _loadingRecords ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: _selectedPatientId != null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              onPressed: _openForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => _selectedPatientId != null ? _loadRecords(_selectedPatientId!) : _loadPatients(),
            icon: const Icon(Icons.refresh), label: const Text('Retry')),
      ]),
    );
  }

  Widget _buildSelectPatient() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Select a patient above', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 8),
        Text('to view their medical records', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No medical records yet', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 8),
        Text('Tap + to add a record', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ]),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => _loadRecords(_selectedPatientId!),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final r = _records[index];
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
                          color: const Color(0xFF9C27B0).withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${r.recordDate.day}/${r.recordDate.month}/${r.recordDate.year}',
                            style: const TextStyle(color: Color(0xFF9C27B0), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      if (r.doctor != null)
                        Text('Dr. ${r.doctor!.fullName}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Diagnosis', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(r.diagnosis, style: const TextStyle(fontSize: 15)),
                  if (r.treatment != null && r.treatment!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Treatment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(r.treatment!, style: const TextStyle(fontSize: 14)),
                  ],
                  if (r.prescription != null && r.prescription!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Prescription', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medication, size: 16, color: Color(0xFFFBBC04)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.prescription!, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                  if (r.notes != null && r.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(r.notes!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
