import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/booking/ai_booking_screen.dart';
import 'package:kayaone/presentation/prescription/prescription_upload_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart'; // Added import
import 'package:provider/provider.dart';
import 'package:kayaone/state/language_provider.dart';
import 'package:kayaone/presentation/doctors/doctor_listing_screen.dart';

class BookingGuideScreen extends StatefulWidget {
  final bool isDoctorBooking;
  const BookingGuideScreen({super.key, required this.isDoctorBooking});

  @override
  State<BookingGuideScreen> createState() => _BookingGuideScreenState();
}

class _BookingGuideScreenState extends State<BookingGuideScreen> {
  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    appLocalizations?.translate('bg_title') ?? "How to Book?",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showLanguageSelector(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            Provider.of<LanguageProvider>(context)
                                .appLocale
                                .languageCode
                                .toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    Text(
                      appLocalizations?.translate('bg_subtitle') ??
                          "Choose your preferred way",
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),
                    _buildStep(
                        Icons.camera_alt_outlined,
                        appLocalizations?.translate('bg_step1_title') ??
                            "Upload Prescription",
                        appLocalizations?.translate('bg_step1_desc') ??
                            "Take a photo of your doctor's note",
                        1),
                    _buildLine(),
                    _buildStep(
                        Icons.calendar_month_outlined,
                        appLocalizations?.translate('bg_step2_title') ??
                            "Choose Slot",
                        appLocalizations?.translate('bg_step2_desc') ??
                            "Select a date and time",
                        2),
                    _buildLine(),
                    _buildStep(
                        Icons.check_circle_outline_rounded,
                        appLocalizations?.translate('bg_step3_title') ??
                            "Confirm",
                        appLocalizations?.translate('bg_step3_desc') ??
                            "Pay securely and relax",
                        3),

                    const SizedBox(height: 48),

                    // AI Button
                    if (!widget.isDoctorBooking) ...[
                      // AI Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AiBookingScreen()));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF6A11CB),
                                Color(0xFF2575FC)
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF2575FC)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8))
                              ]),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.mic_rounded,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        appLocalizations?.translate(
                                                'fast_booking_ai') ??
                                            "Fast Booking with AI",
                                        style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        appLocalizations?.translate(
                                                'speak_to_assistant') ??
                                            "Speak to assistant in your language",
                                        style: GoogleFonts.plusJakartaSans(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white70, size: 16)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Manual Button
                    OutlinedButton(
                      onPressed: () {
                        if (widget.isDoctorBooking) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DoctorListingScreen()));
                        } else {
                          // For Lab tests, start with Prescription upload or default
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PrescriptionUploadScreen()));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(
                              color: AppTheme.darkBlue.withOpacity(0.2))),
                      child: Text(
                          appLocalizations?.translate('book_manually') ??
                              "Book Manually",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.darkBlue)),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String desc, int step) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16)),
          child: Center(
              child: Text("$step",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.primaryGreen))),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(desc,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
        Icon(icon, color: Colors.grey.shade300, size: 28),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
      height: 24,
      width: 2,
      color: Colors.grey.shade200,
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('select_language') ??
                    "Select Language",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: Text("English", style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇮🇳", style: TextStyle(fontSize: 24)),
                title: Text("हिंदी (Hindi)",
                    style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇮🇳", style: TextStyle(fontSize: 24)),
                title: Text("मराठी (Marathi)",
                    style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('mr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
