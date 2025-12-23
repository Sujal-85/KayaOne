import 'package:flutter/material.dart';
import 'package:medinest/core/theme/app_theme.dart';

class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  const BookingStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: LayoutBuilder(builder: (context, constraints) {
        // 4 dots spaced evenly. The space between first and last dot centers.
        // Dot width approx 32 + border/padding ~ 48.
        // Roughly, the line should span from first dot center to last dot center.

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background Line (spanning all dots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 2,
                width: double.infinity,
                color: Colors.grey.shade200,
              ),
            ),
            // Active Line
            if (currentStep > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FractionallySizedBox(
                    widthFactor: currentStep / 3,
                    child: Container(
                      height: 2,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepDot(0, Icons.upload_file_rounded),
                _buildStepDot(1, Icons.location_on_rounded),
                _buildStepDot(2, Icons.calendar_today_rounded),
                _buildStepDot(3, Icons.check_circle_rounded),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepDot(int step, IconData icon) {
    bool isCompleted = step < currentStep;
    bool isActive = step == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isCompleted || isActive ? AppTheme.primaryGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 16,
            color:
                isCompleted || isActive ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
