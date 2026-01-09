import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        title: "Report Generated",
        message:
            "Your recent blood test report (Booking #12345) is ready! Tap to view details.",
        time: "2 mins ago",
        isRead: false,
        type: 'report',
      ),
      _NotificationItem(
        title: "Sample Collected",
        message:
            "Phlebotomist has collected your sample for Booking #12345. It is now en route to the lab.",
        time: "2 hours ago",
        isRead: true,
        type: 'status',
      ),
      _NotificationItem(
        title: "Booking Confirmed",
        message:
            "Your Lab Booking #12345 has been confirmed for Today, 9:00 AM.",
        time: "Yesterday",
        isRead: true,
        type: 'status',
      ),
      _NotificationItem(
        title: "Limited Period Offer!",
        message:
            "Get flat 20% OFF on all heart checkup packages. Valid till Sunday.",
        time: "3 days ago",
        isRead: true,
        type: 'promo',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index])
                    .animate()
                    .fade(duration: 400.ms, delay: (100 * index).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case 'report':
        icon = Icons.file_present_rounded;
        color = Colors.purple;
        break;
      case 'status':
        icon = Icons.check_circle_outline_rounded;
        color = AppTheme.primaryGreen;
        break;
      case 'promo':
        icon = Icons.local_offer_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            item.isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: item.isRead
            ? null
            : Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String type; // report, status, promo

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
