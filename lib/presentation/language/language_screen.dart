import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/presentation/auth/personal_info_screen.dart';
import 'package:kayaone/presentation/home/home_screen.dart';

class LanguageScreen extends StatelessWidget {
  final bool isRegistrationComplete;
  const LanguageScreen({super.key, this.isRegistrationComplete = false});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBlue,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_images/image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Select Language",
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)
                            ?.translate('choose_language') ??
                        'Select your preferred language to continue',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPremiumLanguageCard(
                          context,
                          'English',
                          'English',
                          '🇬🇧',
                          const Locale('en'),
                          languageProvider,
                        ),
                        const SizedBox(height: 20),
                        _buildPremiumLanguageCard(
                          context,
                          'Hindi',
                          'हिंदी',
                          '🇮🇳',
                          const Locale('hi'),
                          languageProvider,
                        ),
                        const SizedBox(height: 20),
                        _buildPremiumLanguageCard(
                          context,
                          'Marathi',
                          'मराठी',
                          '🇮🇳',
                          const Locale('mr'),
                          languageProvider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => isRegistrationComplete
                                ? const HomeScreen()
                                : const PersonalInfoScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('continue') ??
                          'Continue',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLanguageCard(
    BuildContext context,
    String name,
    String nativeName,
    String flag,
    Locale locale,
    LanguageProvider provider,
  ) {
    bool isSelected = provider.appLocale.languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () {
        provider.changeLanguage(locale);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(flag, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isSelected ? Colors.black54 : Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
