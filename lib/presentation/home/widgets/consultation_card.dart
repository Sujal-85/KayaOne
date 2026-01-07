import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConsultationCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ConsultationCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      height: 220, // Increased height to prevent overflow
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Row(
              children: [
                // Text & Button Section (Left)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Book Your\nConsultation Now",
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(),
                        const SizedBox(height: 8),
                        Text(
                          "We're here to help with doctors, slots, or concerns.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D2818),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Consult Now",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().scale(delay: 400.ms),
                      ],
                    ),
                  ),
                ),

                // Image Section (Right)
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Using LayoutBuilder to handle the image sizing gracefully
                      LayoutBuilder(builder: (context, constraints) {
                        return Positioned(
                          bottom: 0,
                          right: -10,
                          child: Image.asset(
                            'assets/images/gaurav.png',
                            height: 320, // Increased size further
                            fit: BoxFit.contain,
                          ).animate().fadeIn(duration: 800.ms).slideX(
                              begin: 0.2, end: 0, curve: Curves.easeOut),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
