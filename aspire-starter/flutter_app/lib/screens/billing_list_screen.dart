import 'package:flutter/material.dart';
import '../models/billing.dart';
import '../services/api_service.dart';

class BillingListScreen extends StatefulWidget {
  const BillingListScreen({super.key});

  @override
  State<BillingListScreen> createState() => _BillingListScreenState();
}

class _BillingListScreenState extends State<BillingListScreen> {
  List<Billing> _bills = [];
  bool _loading = true;
  String? _error;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final bills = await ApiService.getBillings();
      if (mounted) {
        var filtered = bills;
        if (_filterStatus != null) {
          filtered = bills.where((b) => b.status == _filterStatus).toList();
        }
        setState(() { _bills = filtered; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markPaid(Billing bill) async {
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Mark as Paid'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Cash'),
            child: const ListTile(leading: Icon(Icons.money), title: Text('Cash'), contentPadding: EdgeInsets.zero),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Card'),
            child: const ListTile(leading: Icon(Icons.credit_card), title: Text('Card'), contentPadding: EdgeInsets.zero),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Insurance'),
            child: const ListTile(leading: Icon(Icons.health_and_safety), title: Text('Insurance'), contentPadding: EdgeInsets.zero),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Online'),
            child: const ListTile(leading: Icon(Icons.payments), title: Text('Online Transfer'), contentPadding: EdgeInsets.zero),
          ),
        ],
      ),
    );

    if (method != null) {
      try {
        await ApiService.markBillPaid(bill.id, method, amount: bill.dueAmount);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bill marked as paid ($method)'), backgroundColor: const Color(0xFF34A853)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid': return const Color(0xFF34A853);
      case 'Partial': return const Color(0xFFFBBC04);
      case 'Unpaid': return const Color(0xFFEA4335);
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
            child: DropdownButtonFormField<String?>(
              value: _filterStatus,
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Bills')),
                const DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                const DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                const DropdownMenuItem(value: 'Paid', child: Text('Paid')),
              ],
              onChanged: (v) { setState(() => _filterStatus = v); _load(); },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null ? _buildError()
                : _bills.isEmpty ? _buildEmpty()
                : _buildList(),
          ),
        ],
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
        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No bills found', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bills.length,
        itemBuilder: (context, index) {
          final b = _bills[index];
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
                          color: _statusColor(b.status).withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(b.status, style: TextStyle(color: _statusColor(b.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Text(b.invoiceNumber, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF1A73E8)),
                      const SizedBox(width: 6),
                      Text(b.patient?.fullName ?? 'Patient #${b.patientId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: \$${b.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Text('Paid: \$${b.paidAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            if (b.dueAmount > 0)
                              Text('Due: \$${b.dueAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEA4335), fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (b.status != 'Paid' && b.status != 'Cancelled')
                        FilledButton.icon(
                          icon: const Icon(Icons.payments, size: 16),
                          label: const Text('Pay', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF34A853)),
                          onPressed: () => _markPaid(b),
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
