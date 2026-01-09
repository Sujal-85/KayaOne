import 'package:flutter/material.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kayaone/core/utils/whatsapp_helper.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => WhatsAppHelper.launchWhatsApp(
            message: "Hi, I need help with my medical reports."),
        backgroundColor: const Color(0xFF25D366),
        child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      ),
    );
  }
}
