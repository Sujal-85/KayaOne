import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/language_provider.dart';

class ProfileLanguageScreen extends StatelessWidget {
  const ProfileLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Select Language",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLanguageOption(
              context,
              "English",
              "English",
              "🇬🇧",
              const Locale('en'),
              languageProvider,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              context,
              "Hindi",
              "हिंदी",
              "🇮🇳",
              const Locale('hi'),
              languageProvider,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              context,
              "Marathi",
              "मराठी",
              "🇮🇳",
              const Locale('mr'),
              languageProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Language changed to $name"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nativeName,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppTheme.darkBlue)),
                Text(name,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primaryGreen, size: 28),
          ],
        ),
      ),
    );
  }
}
