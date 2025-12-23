import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medinest/core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / App Name
            Text(
              "MediNest",
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkBlue,
                letterSpacing: -1,
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            Text(
              "Your Smart Health Companion",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

            const SizedBox(height: 48),

            // The Blue Loader
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.darkBlue),
                backgroundColor: AppTheme.darkBlue.withOpacity(0.1),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
