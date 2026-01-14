import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/booking_provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Consumer<BookingProvider>(builder: (context, provider, child) {
          final test = provider.selectedTests.isNotEmpty
              ? provider.selectedTests.first
              : null;
          final String title = test?['name'] ?? "Medical Appointment";
          final String subtitle = test?['category'] ?? "General Service";

          return Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 180,
                          child: Lottie.asset(
                            'assets/lottie/done.json',
                            repeat: false,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.check_circle_rounded,
                                  color: Colors.green, size: 100);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Booking Confirmed!",
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your appointment has been successfully scheduled.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Order Details Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(Icons.medical_services_outlined,
                                  title, subtitle),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider()),
                              _buildDetailRow(
                                  Icons.calendar_today_rounded,
                                  provider.selectedDate ?? "Date",
                                  provider.selectedSlot ?? "Time"),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider()),
                              _buildDetailRow(
                                  Icons.person_outline_rounded,
                                  provider.patientName ?? "Patient",
                                  provider.patientPhone ?? "Phone"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkBlue,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Back to Home",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.darkBlue, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            Text(subtitle,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: Colors.grey.shade600)),
          ],
        )
      ],
    );
  }
}
