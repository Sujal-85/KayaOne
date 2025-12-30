import 'package:flutter/material.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text("Track Order")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order ID: #MN-98721",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("20 Dec 2025", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildTrackStep("Order Placed", "10:30 AM", true, true),
                  _buildTrackStep(
                      "Phlebotomist Assigned", "10:45 AM", true, true),
                  _buildTrackStep(
                      "Sample Collection", "On the way", true, false),
                  _buildTrackStep("Lab Processing", "Pending", false, false),
                  _buildTrackStep("Report Generated", "Pending", false, false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Phlebotomist Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.darkBlue.withOpacity(0.1),
                    child: const Icon(Icons.person,
                        size: 30, color: AppTheme.darkBlue),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rahul Sharma",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Certified Phlebotomist",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.green),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackStep(
      String title, String subtitle, bool isDone, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.secondaryColor : Colors.grey.shade300,
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone ? AppTheme.secondaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? AppTheme.darkBlue : Colors.grey)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
