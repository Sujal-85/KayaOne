import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgrounds = [
      'assets/images/splash_images/image.png',
      'assets/images/splash_images/image1.png',
      'assets/images/splash_images/image2.png',
      'assets/images/splash_images/image3.png',
    ];
    // Randomly select one
    final randomBg = backgrounds[Random().nextInt(backgrounds.length)];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            randomBg,
            fit: BoxFit.cover,
          ),

          // 2. Dark Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),

          // 3. Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / App Name
                Text(
                  "KayaOne",
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // Changed to white for contrast
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  "Your Smart Health Companion",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8), // Lighter text
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                const SizedBox(height: 48),

                // The Loader (White to match dark bg)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
