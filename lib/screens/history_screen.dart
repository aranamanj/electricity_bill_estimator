import 'package:flutter/material.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int refreshTick;
  const HistoryScreen({super.key, this.refreshTick = 0});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BillRecord> _records = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void didUpdateWidget(HistoryScreen old) {
    super.didUpdateWidget(old);
    // Reload whenever the parent bumps refreshTick (tab switch)
    if (old.refreshTick != widget.refreshTick) _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final records = await DatabaseHelper.instance.getAllRecords();
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_rounded, color: Colors.amber),
          SizedBox(width: 6),
          Text('Bill History'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 12),
          Text('Error loading records:\n$_error',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: _loadRecords, child: const Text('Retry')),
        ]),
      );
    }
    if (_records.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No records yet',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Calculate and save a bill to see it here.',
              style: TextStyle(color: Colors.grey[500])),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _records.length,
        itemBuilder: (ctx, i) {
          final r = _records[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0D47A1),
                child: Text(
                  r.month.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(r.month,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${r.units.toStringAsFixed(0)} kWh  •  '
                'Rebate ${r.rebatePercent.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${r.finalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1)),
                  ),
                  Text('Final Cost',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailScreen(record: r)),
                );
                _loadRecords(); // refresh after returning
              },
            ),
          );
        },
      ),
    );
  }
}