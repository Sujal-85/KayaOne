import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/core/utils/booking_status_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookingStatusTracker extends StatelessWidget {
  final BookingStage currentStage;

  const BookingStatusTracker({super.key, required this.currentStage});

  @override
  Widget build(BuildContext context) {
    final stages = BookingStage.values;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Track Your Booking",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              return _buildTimelineStep(context, stage, index, stages.length);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
      BuildContext context, BookingStage stage, int index, int total) {
    final isCompleted = stage.index < currentStage.index;
    final isCurrent = stage.index == currentStage.index;
    final isLast = index == total - 1;

    Color color;
    if (isCompleted) {
      color = Colors.green;
    } else if (isCurrent) {
      color = AppTheme.primaryGreen;
    } else {
      color = Colors.grey.shade300;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Dot
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? color.withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 16, color: color)
                      : isCurrent
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            )
                              .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true))
                              .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.2, 1.2),
                                  duration: 1.seconds)
                          : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BookingStatusHelper.getTitle(stage),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCompleted || isCurrent
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCurrent)
                    Text(
                      BookingStatusHelper.getDescription(stage),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ).animate().fadeIn().slideX(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
