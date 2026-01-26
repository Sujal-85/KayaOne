import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/presentation/home/home_screen.dart';

class ConsultationCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ConsultationCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // LEFT SIDE: Text and Button
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations?.translate('your_health_priority') ??
                        "Book Your,\nConsultation Now",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.darkBlue,
                      height: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    appLocalizations?.translate('expert_care_desc') ??
                        "Expert care and guidance for a healthier you.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => HomeScreenState.of(context)?.setIndex(2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F), // Olive Green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      child: Text(
                        appLocalizations?.translate('get_started') ??
                            "Get Started",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(),
                ],
              ),
            ),

            // RIGHT SIDE: Image with Circle
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Green Circle Ring
                    Positioned(
                      right: 0,
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF9E9D24).withOpacity(0.5),
                            width: 6,
                          ),
                        ),
                      ),
                    ),
                    // Image
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Image.asset(
                        'assets/images/priyanka.png',
                        fit: BoxFit.contain,
                        height: 150,
                      ),
                    ),
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
