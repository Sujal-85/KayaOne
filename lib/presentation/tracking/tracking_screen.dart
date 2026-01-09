import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/data/services/booking_service.dart';
import 'package:kayaone/data/services/notification_service.dart';
import 'package:kayaone/state/notification_provider.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatefulWidget {
  final String? bookingId;
  const TrackingScreen({super.key, this.bookingId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final BookingService _bookingService = BookingService();
  Map<String, dynamic>? _bookingData;
  bool _isLoading = true;
  Timer? _timer;
  String? _previousStatus;

  // Static timeline configuration
  final List<String> _timelineSteps = [
    "Confirmed",
    "Phlebotomist Assigned",
    "Out for Collection",
    "Sample Collected",
    "Lab Processing",
    "Report Generated",
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (widget.bookingId != null) _fetchBookingDetails(silent: true);
    });
  }

  Future<void> _fetchBookingDetails({bool silent = false}) async {
    if (widget.bookingId == null) return;

    final data = await _bookingService.getBookingById(widget.bookingId!);
    if (mounted && data != null) {
      final currentStatus = data['status'];

      // Trigger notification if status changed and it's not the first load
      if (_previousStatus != null && _previousStatus != currentStatus) {
        // Show Local Notification
        NotificationService().showNotification(
            title: "Booking Status Updated",
            body: "Your booking is now $currentStatus");

        // Add to In-App Notifications
        Provider.of<NotificationProvider>(context, listen: false)
            .addNotification("Booking Status Updated",
                "Your booking status has changed to $currentStatus");
      }

      _previousStatus = currentStatus;

      setState(() {
        _bookingData = data;
        if (!silent) _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header Content
            Positioned(
              top: 60,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Track Status",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // White Container
            Container(
              margin: const EdgeInsets.only(top: 140),
              height: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ]),
              child: SingleChildScrollView(
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
                                _bookingData != null
                                    ? "#${_bookingData!['_id'].toString().substring(18).toUpperCase()}"
                                    : "Loading...",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _bookingData != null
                                  ? (_bookingData!['status'] ?? "PENDING")
                                      .toString()
                                      .toUpperCase()
                                  : "LOADING...",
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
                      itemCount: _timelineSteps.length,
                      itemBuilder: (context, index) {
                        final stepTitle = _timelineSteps[index];
                        final isLast = index == _timelineSteps.length - 1;

                        // Calculate status logic
                        final currentStatus =
                            _bookingData?['status'] ?? 'Pending';
                        final stepStatusIndex =
                            _timelineSteps.indexOf(stepTitle);
                        // Map backend status to index in our list (approximate)
                        int currentStatusIndex = -1;

                        // Handle mapping because backend status strings might match or be slightly different
                        // Or we simply check if this step is "done" based on hierarchy
                        // Hierarchy: Pending -> Confirmed -> Phlebotomist Assigned -> Out -> Sample -> Lab -> Report -> Completed

                        // Simple index based logic if strings match exactly (except 'Completed' matches Report Generated)
                        if (_bookingData != null) {
                          if (currentStatus == 'Completed') {
                            currentStatusIndex = 5;
                          } else if (currentStatus == 'Report Generated')
                            currentStatusIndex = 5;
                          else if (currentStatus == 'Lab Processing')
                            currentStatusIndex = 4;
                          else if (currentStatus == 'Sample Collected')
                            currentStatusIndex = 3;
                          else if (currentStatus == 'Out for Collection')
                            currentStatusIndex = 2;
                          else if (currentStatus == 'Phlebotomist Assigned')
                            currentStatusIndex = 1;
                          else if (currentStatus == 'Confirmed')
                            currentStatusIndex = 0;
                          else
                            currentStatusIndex = -1; // Pending
                        }

                        final bool isCompleted =
                            stepStatusIndex <= currentStatusIndex;
                        final bool isCurrent = stepStatusIndex ==
                            currentStatusIndex +
                                1; // Next step is current? Or current is completed?
                        // Actually "isCurrent" usually means "In Progress".
                        // If currentStatus is "Phlebotomist Assigned", then that step is DONE.
                        // Let's say:
                        // isCompleted = index <= currentIndex
                        // isCurrent = index == currentIndex (The one just finished? or the next one?)
                        // "Out for Collection" implies it IS out. So it is ACTIVE.
                        // So if status is 'Out for Collection' (index 2), then step 2 is "Current/Active". steps 0,1 are Completed.

                        bool isStepCompleted =
                            stepStatusIndex < currentStatusIndex;
                        bool isStepCurrent =
                            stepStatusIndex == currentStatusIndex;
                        // If status matches step, it is Current (green blinking). Previous are completed (green check). Next are grey.

                        // Exception: "Report Generated" (index 5) is the last one. If done, it remains Completed (Green Check).
                        if (currentStatusIndex == 5 && stepStatusIndex == 5) {
                          isStepCompleted = true;
                          isStepCurrent = false;
                        }

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
                                    color: isStepCompleted
                                        ? AppTheme.primaryGreen
                                        : isStepCurrent
                                            ? Colors.white
                                            : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isStepCompleted || isStepCurrent
                                          ? AppTheme.primaryGreen
                                          : Colors.grey.shade300,
                                      width: isStepCurrent ? 6 : 2,
                                    ),
                                  ),
                                  child: isStepCompleted
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                )
                                    .animate(target: isStepCurrent ? 1 : 0)
                                    .effect(
                                        duration: 1000.ms,
                                        curve: Curves.easeInOut)
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
                                    height: 50,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isStepCompleted
                                          ? AppTheme.primaryGreen
                                              .withOpacity(0.5)
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
                                      stepTitle,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight:
                                            isStepCurrent || isStepCompleted
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        color: isStepCurrent || isStepCompleted
                                            ? AppTheme.darkBlue
                                            : Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Optionally show timestamp if available in history
                                    // For now, simple text
                                    Text(
                                      isStepCompleted
                                          ? "Completed"
                                          : (isStepCurrent
                                              ? "In Progress"
                                              : "Pending"),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isStepCurrent
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                      ),
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
                    if (_bookingData?['phlebotomist'] != null) ...[
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
                                image: _bookingData!['phlebotomist']
                                            ['photoUrl'] !=
                                        null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            _bookingData!['phlebotomist']
                                                ['photoUrl']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _bookingData!['phlebotomist']
                                          ['photoUrl'] ==
                                      null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _bookingData!['phlebotomist']['name'] ??
                                        "Phlebotomist",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkBlue,
                                    ),
                                  ),
                                  Text(
                                    "Certified Phlebotomist • ${_bookingData!['phlebotomist']['rating'] ?? 5.0} ★",
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
                                onPressed: () {
                                  // Call logic will go here
                                  // launch("tel:${_bookingData!['phlebotomist']['phone']}");
                                },
                                icon: const Icon(Icons.call_rounded,
                                    color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
