import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class PremiumPopup extends StatelessWidget {
  final String title;
  final String content;
  final String imagePath;
  final String btnText;
  final VoidCallback onBtn;
  final Color? accentColor;

  const PremiumPopup({
    super.key,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.btnText,
    required this.onBtn,
    this.accentColor,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required String imagePath,
    required String btnText,
    required VoidCallback onBtn,
    Color? accentColor,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.4), // Darker backdrop
      pageBuilder: (context, anim1, anim2) {
        return Container(); // Not used because transitionBuilder handles logic
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return PremiumPopup(
          title: title,
          content: content,
          imagePath: imagePath,
          btnText: btnText,
          onBtn: onBtn,
          accentColor: accentColor,
        )
            .animate(target: anim1.value)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
              duration: 400.ms,
            )
            .fade(duration: 200.ms);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Glassmorphism effect
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85), // Frosted glass
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (accentColor ?? AppTheme.primaryGreen).withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon/Image Container with Glow
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: (accentColor ?? AppTheme.primaryGreen)
                                .withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: accentColor ?? AppTheme.primaryGreen,
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  // Title with Gradient/Style
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),

                  const SizedBox(height: 28),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onBtn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor ?? AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: (accentColor ?? AppTheme.primaryGreen)
                            .withOpacity(0.4),
                      ).copyWith(
                        elevation: MaterialStateProperty.all(8),
                      ),
                      child: Text(
                        btnText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .shimmer(duration: 1500.ms, delay: 1000.ms),

                  const SizedBox(height: 12),

                  // Close Button (Subtle)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Dismiss",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
