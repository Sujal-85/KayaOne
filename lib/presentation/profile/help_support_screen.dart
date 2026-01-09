import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
            // Header
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
                  const SizedBox(width: 16),
                  Text(
                    appLocalizations?.translate('help_support') ??
                        "Help & Support",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content Container
            Container(
              margin: const EdgeInsets.only(top: 120),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations?.translate('faq_title') ??
                          "Frequently Asked Questions",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                        context,
                        appLocalizations?.translate('help_faq_1_q') ??
                            "How do I book an appointment?",
                        appLocalizations?.translate('help_faq_1_a') ??
                            "You can book an appointment by selecting 'Book Slot Now' or 'Find a Doctor' from the home screen."),
                    _buildFaqItem(
                        context,
                        appLocalizations?.translate('help_faq_2_q') ??
                            "Can I cancel my booking?",
                        appLocalizations?.translate('help_faq_2_a') ??
                            "Yes, you can cancel your booking from the 'My Bookings' section up to 2 hours before the appointment."),
                    _buildFaqItem(
                        context,
                        appLocalizations?.translate('help_faq_3_q') ??
                            "How do I download my prescription?",
                        appLocalizations?.translate('help_faq_3_a') ??
                            "Go to 'My Appointments', select the completed appointment, and tap 'Download Prescription'."),
                    _buildFaqItem(
                        context,
                        appLocalizations?.translate('help_faq_4_q') ??
                            "Is my data safe?",
                        appLocalizations?.translate('help_faq_4_a') ??
                            "Yes, we use industry-standard encryption to protect your personal and medical data."),

                    const SizedBox(height: 32),

                    Text(
                      appLocalizations?.translate('still_need_help') ??
                          "Still need help?",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contact Support Button
                    GestureDetector(
                      onTap: () {
                        // Implement contact support logic (e.g., email or call)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(appLocalizations
                                    ?.translate('contacting_support') ??
                                "Contacting support...")));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.headset_mic_rounded,
                                  color: AppTheme.primaryGreen),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appLocalizations
                                          ?.translate('contact_cust_care') ??
                                      "Contact Customer Care",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkBlue,
                                  ),
                                ),
                                Text(
                                  appLocalizations?.translate('here_to_help') ??
                                      "We are here to help 24/7",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: Colors.grey),
                          ],
                        ),
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

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
