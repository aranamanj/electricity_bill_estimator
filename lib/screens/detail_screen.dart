import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';
import '../utils/calculator.dart';

class DetailScreen extends StatefulWidget {
  final BillRecord record;
  const DetailScreen({super.key, required this.record});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late BillRecord _record;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitsCtrl;
  String? _editMonth;
  double _editRebate = 0;

  static const List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _seedEditFields();
  }

  void _seedEditFields() {
    _unitsCtrl =
        TextEditingController(text: _record.units.toStringAsFixed(0));
    _editMonth = _record.month;
    _editRebate = _record.rebatePercent;
  }

  @override
  void dispose() {
    _unitsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;

    final units = double.parse(_unitsCtrl.text);
    final total = ElectricityCalculator.calculateTotalCharges(units);
    final finalCost =
        ElectricityCalculator.calculateFinalCost(total, _editRebate);

    final updated = BillRecord(
      id: _record.id,
      month: _editMonth!,
      units: units,
      rebatePercent: _editRebate,
      totalCharges: total,
      finalCost: finalCost,
    );

    await DatabaseHelper.instance.updateRecord(updated);
    setState(() {
      _record = updated;
      _isEditing = false;
    });
    _showSnack('Record updated!', Colors.green);
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
            'Delete the record for ${_record.month}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && _record.id != null) {
      await DatabaseHelper.instance.deleteRecord(_record.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Record deleted.'),
              backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Bill Details'),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel',
                  onPressed: () {
                    _unitsCtrl.dispose();
                    setState(() {
                      _isEditing = false;
                      _seedEditFields();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  tooltip: 'Delete',
                  onPressed: _deleteRecord,
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isEditing ? _editForm() : _detailView(),
      ),
    );
  }

  // ── Detail view ────────────────────────────
  Widget _detailView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Header card
      Card(
        color: const Color(0xFF0D47A1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Icon(Icons.receipt_long_outlined,
                color: Colors.amber, size: 44),
            const SizedBox(height: 8),
            Text(_record.month,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('Record #${_record.id}',
                style: const TextStyle(color: Colors.white60)),
          ]),
        ),
      ),
      const SizedBox(height: 14),

      // Inputs
      _section('Input Details', [
        _row(Icons.calendar_month_outlined, 'Month', _record.month),
        _row(Icons.electric_meter_outlined, 'Units Used',
            '${_record.units.toStringAsFixed(0)} kWh'),
        _row(Icons.discount_outlined, 'Rebate',
            '${_record.rebatePercent.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 12),

      // Outputs
      _section('Calculation Results', [
        _row(Icons.receipt_outlined, 'Total Charges',
            'RM ${_record.totalCharges.toStringAsFixed(2)}'),
        const Divider(height: 16),
        Row(children: [
          const Icon(Icons.payments_outlined,
              color: Color(0xFF0D47A1), size: 22),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Final Cost (After Rebate)',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Text('RM ${_record.finalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1))),
        ]),
      ]),
      const SizedBox(height: 20),

      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deleteRecord,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
      ]),
    ]);
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1))),
          const Divider(height: 16),
          ...children,
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.grey))),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Edit form ──────────────────────────────
  Widget _editForm() {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Modify the fields below. Charges will be recalculated automatically.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _editMonth,
          decoration: const InputDecoration(
            labelText: 'Billing Month *',
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
          items: _months
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => setState(() => _editMonth = v),
          validator: (v) => v == null ? 'Select a month' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _unitsCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Units Used (kWh) *',
            prefixIcon: Icon(Icons.electric_meter_outlined),
            suffixText: 'kWh',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            final n = double.tryParse(v);
            if (n == null) return 'Invalid number';
            if (n < 1) return 'Min 1 kWh';
            if (n > 1000) return 'Max 1000 kWh';
            return null;
          },
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.discount_outlined,
                      size: 18, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Rebate Percentage')),
                  Text('${_editRebate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                Slider(
                  value: _editRebate,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  onChanged: (v) => setState(() => _editRebate = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _saveEdit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Changes'),
        ),
      ]),
    );
  }
}