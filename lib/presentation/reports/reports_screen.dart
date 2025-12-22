import 'package:flutter/material.dart';
import 'package:medinest/core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  final List<Map<String, String>> _reports = const [
    {'date': '15 Dec 2025', 'name': 'Full Body Checkup', 'status': 'Available'},
    {'date': '10 Nov 2025', 'name': 'Vitamin D Test', 'status': 'Available'},
    {'date': '02 Oct 2025', 'name': 'Thyroid Profile', 'status': 'Available'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text("Medical Reports")),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppTheme.darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.darkBlue),
              ),
              title: Text(report['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(report['date']!),
              trailing: const Icon(Icons.download_rounded,
                  color: AppTheme.secondaryColor),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Downloading Report...")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
