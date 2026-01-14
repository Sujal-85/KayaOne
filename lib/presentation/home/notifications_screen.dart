import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/notification_provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) => provider.notifications.isNotEmpty
                ? TextButton(
                    onPressed: () => provider.markAllAsRead(),
                    child: Text(
                      "Mark all read",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/no_doctor.json',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No Notifications Yet",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll notify you for new message.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupNotifications(provider.notifications);
          final keys = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final label = keys[index];
              final items = grouped[label]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(label),
                  ...items.map((n) => _buildNotificationItem(
                        icon: _getIconForTitle(n.title),
                        color: _getColorForTitle(n.title),
                        title: n.title,
                        desc: n.body,
                        time: _getTimeLabel(n.timestamp),
                        isUnread: !n.isRead,
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(
      List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> groups = {};
    for (var n in notifications) {
      final label = _getDateLabel(n.timestamp);
      groups.putIfAbsent(label, () => []).add(n);
    }
    return groups;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return "Today";
    if (d == yesterday) return "Yesterday";
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _getTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return DateFormat('HH:mm').format(dateTime);
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('appointment')) return Icons.calendar_today_rounded;
    if (t.contains('report')) return Icons.bloodtype_rounded;
    if (t.contains('order')) return Icons.shopping_bag_rounded;
    if (t.contains('offer')) return Icons.local_offer_rounded;
    return Icons.notifications_rounded;
  }

  Color _getColorForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('appointment')) return Colors.blue;
    if (t.contains('report')) return Colors.redAccent;
    if (t.contains('order')) return Colors.purple;
    if (t.contains('offer')) return Colors.orange;
    return AppTheme.primaryGreen;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.1) : Colors.grey.shade100,
        ),
        boxShadow: [
          if (!isUnread)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8), // Added spacing
                    Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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
