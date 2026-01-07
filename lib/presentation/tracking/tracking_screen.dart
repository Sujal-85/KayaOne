import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Mock Data for the Journey
  final List<Map<String, dynamic>> _steps = [
    {
      "title": "Booking Confirmed",
      "description": "Your appointment has been successfully booked.",
      "time": "Sat, 20 Dec • 09:30 AM",
      "status": "completed",
    },
    {
      "title": "Phlebotomist Assigned",
      "description": "Rahul Sharma (4.8 ★) will reach your location.",
      "time": "Sat, 20 Dec • 09:45 AM",
      "status": "completed",
    },
    {
      "title": "Out for Collection",
      "description": "Phlebotomist is on the way to your home.",
      "time": "Today • 10:15 AM",
      "status": "current", // This is the active blinking step
    },
    {
      "title": "Sample Collected",
      "description": "Blood sample collected and sealed safe.",
      "time": "Expected • 10:45 AM",
      "status": "pending",
    },
    {
      "title": "Lab Processing",
      "description": "Sample reached lab for analysis.",
      "time": "Expected • 12:30 PM",
      "status": "pending",
    },
    {
      "title": "Report Generated",
      "description": "Your health report will be ready to download.",
      "time": "Expected • 06:00 PM",
      "status": "pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          "Track Status",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.darkBlue, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Order ID Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "#MN-98721",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "IN PROGRESS",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Journey Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final bool isLast = index == _steps.length - 1;
                final String status = step['status'];
                final bool isCompleted = status == 'completed';
                final bool isCurrent = status == 'current';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Indicator
                    Column(
                      children: [
                        // Indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.primaryGreen
                                : isCurrent
                                    ? Colors.white
                                    : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? AppTheme.primaryGreen
                                  : isCurrent
                                      ? AppTheme.primaryGreen
                                      : Colors.grey.shade300,
                              width: isCurrent ? 6 : 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        )
                            .animate(
                                target: isCurrent ? 1 : 0) // Animate if current
                            .effect(
                                duration: 1000.ms,
                                curve: Curves.easeInOut) // Pulse effect setup
                            .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2))
                            .then()
                            .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(1, 1)),

                        // Line
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppTheme.primaryGreen.withOpacity(0.5)
                                  : Colors.grey[200],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: isCurrent || isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isCurrent || isCompleted
                                    ? AppTheme.darkBlue
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step['description'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isCurrent
                                    ? Colors.grey[800]
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(
                                  step['time'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 3. Phlebotomist Card (Conditional: if assigned)
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.grey), // Placeholder for image
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rahul Sharma",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        Text(
                          "Certified Phlebotomist • 4.8 ★",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call_rounded,
                          color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
