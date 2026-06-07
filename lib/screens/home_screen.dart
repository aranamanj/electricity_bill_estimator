import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';
import '../utils/calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();

  String? _selectedMonth;
  double _rebatePercent = 0.0;
  double? _totalCharges;
  double? _finalCost;
  bool _hasResult = false;

  static const List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  // ── Calculate ──────────────────────────────
  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMonth == null) {
      _showSnack('Please select a month.', Colors.orange);
      return;
    }

    final units = double.parse(_unitsController.text);
    final total = ElectricityCalculator.calculateTotalCharges(units);
    final finalCost =
        ElectricityCalculator.calculateFinalCost(total, _rebatePercent);

    setState(() {
      _totalCharges = total;
      _finalCost = finalCost;
      _hasResult = true;
    });
  }

  // ── Save to DB ─────────────────────────────
  Future<void> _saveRecord() async {
    if (!_hasResult) {
      _showSnack('Calculate the bill first before saving.', Colors.orange);
      return;
    }

    final record = BillRecord(
      month: _selectedMonth!,
      units: double.parse(_unitsController.text),
      rebatePercent: _rebatePercent,
      totalCharges: _totalCharges!,
      finalCost: _finalCost!,
    );

    await DatabaseHelper.instance.insertRecord(record);
    _showSnack('Record saved successfully!', Colors.green);
    _resetForm();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _unitsController.clear();
    setState(() {
      _selectedMonth = null;
      _rebatePercent = 0.0;
      _totalCharges = null;
      _finalCost = null;
      _hasResult = false;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bolt, color: Colors.amber),
          SizedBox(width: 6),
          Text('ElecBill Estimator'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
            onPressed: _resetForm,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Instruction card ────────────
              _InfoCard(
                icon: Icons.info_outline,
                color: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF0D47A1),
                text:
                    'Select a month, enter your electricity usage (kWh), '
                    'set the rebate, then tap Calculate.',
              ),
              const SizedBox(height: 16),

              // ── Month dropdown ───────────────
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Billing Month *',
                  hintText: 'Select month',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                items: _months
                    .map((m) =>
                        DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) =>
                    setState(() {
                      _selectedMonth = v;
                      _hasResult = false;
                    }),
                validator: (v) =>
                    v == null ? 'Please select a month' : null,
              ),
              const SizedBox(height: 14),

              // ── Units field ──────────────────
              TextFormField(
                controller: _unitsController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Electricity Units Used *',
                  hintText: 'e.g. 350',
                  prefixIcon: Icon(Icons.electric_meter_outlined),
                  suffixText: 'kWh',
                  helperText: 'Enter a value between 1 and 1000 kWh',
                ),
                onChanged: (_) => setState(() => _hasResult = false),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Units are required';
                  final n = double.tryParse(v);
                  if (n == null) return 'Enter a valid number';
                  if (n < 1) return 'Minimum is 1 kWh';
                  if (n > 1000) return 'Maximum is 1000 kWh';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // ── Rebate slider ────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.discount_outlined,
                              size: 20, color: Color(0xFF0D47A1)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Rebate Percentage',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_rebatePercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _rebatePercent,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: '${_rebatePercent.toStringAsFixed(1)}%',
                        onChanged: (v) => setState(() {
                          _rebatePercent = v;
                          _hasResult = false;
                        }),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0%',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12)),
                            Text('5%',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tariff reference (collapsible) ──
              _TariffTable(),
              const SizedBox(height: 20),

              // ── Calculate button ─────────────
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate Bill',
                    style: TextStyle(fontSize: 16)),
              ),

              // ── Result card ──────────────────
              if (_hasResult) ...[
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFF0D47A1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('📊  Calculation Results',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const Divider(color: Colors.white38, height: 22),
                        _resultRow(Icons.calendar_today_outlined,
                            'Month', _selectedMonth!),
                        _resultRow(Icons.electric_meter_outlined,
                            'Units Used',
                            '${_unitsController.text} kWh'),
                        _resultRow(Icons.discount_outlined, 'Rebate',
                            '${_rebatePercent.toStringAsFixed(1)}%'),
                        const Divider(color: Colors.white38, height: 22),
                        _resultRow(Icons.receipt_outlined,
                            'Total Charges',
                            'RM ${_totalCharges!.toStringAsFixed(2)}'),
                        const SizedBox(height: 10),
                        // Final cost highlight
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined,
                                  color: Color(0xFF0D47A1)),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Final Cost (After Rebate)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1))),
                              ),
                              Text(
                                'RM ${_finalCost!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saveRecord,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Record'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    side:
                        BorderSide(color: scheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white70))),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable info card widget
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(color: iconColor, fontSize: 13))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Collapsible tariff reference table
// ─────────────────────────────────────────────
class _TariffTable extends StatefulWidget {
  @override
  State<_TariffTable> createState() => _TariffTableState();
}

class _TariffTableState extends State<_TariffTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart_outlined,
                color: Color(0xFF0D47A1)),
            title: const Text('View Tariff Rates',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                },
                border: TableBorder.all(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)),
                children: [
                  _header(),
                  _row('1 – 200 kWh', '21.8 sen/kWh'),
                  _row('201 – 300 kWh', '33.4 sen/kWh'),
                  _row('301 – 600 kWh', '51.6 sen/kWh'),
                  _row('601 – 1000 kWh', '54.6 sen/kWh'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TableRow _header() => const TableRow(
        decoration: BoxDecoration(color: Color(0xFF0D47A1)),
        children: [
          Padding(
              padding: EdgeInsets.all(8),
              child: Text('Block',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text('Rate',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      );

  TableRow _row(String block, String rate) => TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(8), child: Text(block)),
        Padding(
            padding: const EdgeInsets.all(8), child: Text(rate)),
      ]);
}