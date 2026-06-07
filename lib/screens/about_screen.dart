import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _fullName   = 'Aran Amanj Othman';
  static const String _studentId  = 'QIU23-0183';
  static const String _courseCode = 'ICT602';
  static const String _courseName = 'Mobile Technology and Development';
  static const String _githubUrl  =
      'https://github.com/';
  static const int _year = 2026;

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(_githubUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_rounded, color: Colors.amber),
          SizedBox(width: 6),
          Text('About'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Developer profile ──────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                    CircleAvatar(
                      radius: 52,
                       backgroundImage: AssetImage('assets/images/profile.jpg'),
                     ),
                  //const CircleAvatar(
                  //  radius: 52,
                  //  backgroundColor: Color(0xFF0D47A1),
                   // child: Icon(Icons.person, size: 60, color: Colors.white),
                 // ),
                  const SizedBox(height: 14),
                  Text(_fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Student ID: $_studentId',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text('$_courseCode  –  $_courseName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 14),
                  Text(
                    '© $_year $_fullName. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Clickable GitHub URL
                  InkWell(
                    onTap: () => _launch(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.link_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('View App on GitHub',
                            style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // ── App description ─────────────────
            _section(
              icon: Icons.bolt_rounded,
              title: 'About This App',
              child: const Text(
                'Electricity Bill Estimator helps Malaysian households '
                'estimate their monthly TNB electricity bill. Enter your '
                'consumption in kWh and any applicable rebate; the app '
                'applies the official tiered tariff and shows your total '
                'charges plus the final cost after the rebate. All records '
                'are stored offline for future reference.',
              ),
            ),
            const SizedBox(height: 12),

            // ── How to use ──────────────────────
            _section(
              icon: Icons.help_outline_rounded,
              title: 'How to Use',
              child: Column(
                children: [
                  _step('1',
                      'On the Calculator tab, select the billing month from the dropdown.'),
                  _step('2',
                      'Type the number of electricity units used (1 – 1000 kWh).'),
                  _step('3',
                      'Drag the Rebate slider to set a rebate between 0% and 5%.'),
                  _step('4',
                      'Tap Calculate Bill to see Total Charges and Final Cost instantly.'),
                  _step('5',
                      'Tap Save Record to store the result in the local database.'),
                  _step('6',
                      'Switch to the History tab to see all saved bills (month & final cost).'),
                  _step('7',
                      'Tap any record to view full details, edit values, or delete the record.'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Tariff table ────────────────────
            _section(
              icon: Icons.table_chart_outlined,
              title: 'Tariff Rates (TNB Domestic)',
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                },
                border: TableBorder.all(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)),
                children: [
                  _tableHeader(),
                  _tableRow('1 – 200 kWh', '21.8 sen/kWh'),
                  _tableRow('201 – 300 kWh', '33.4 sen/kWh'),
                  _tableRow('301 – 600 kWh', '51.6 sen/kWh'),
                  _tableRow('601 – 1000 kWh', '54.6 sen/kWh'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────
  static Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF0D47A1)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1))),
          ]),
          const Divider(height: 16),
          child,
        ]),
      ),
    );
  }

  static Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF0D47A1),
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ]),
    );
  }

  static TableRow _tableHeader() => const TableRow(
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

  static TableRow _tableRow(String block, String rate) => TableRow(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(block)),
        Padding(padding: const EdgeInsets.all(8), child: Text(rate)),
      ]);
}