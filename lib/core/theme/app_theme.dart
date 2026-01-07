import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Blue & Green Palette
  static const Color darkBlue = Color(0xFF0F3460);
  static const Color mediumBlue = Color(0xFF16213E);
  static const Color lightBlue = Color(0xFF1A1A2E);

  static const Color primaryGreen = Color(0xFF4ECCA3);
  static const Color accentGreen = Color(0xFF00ADB5);

  static const Color primaryColor = darkBlue;
  static const Color secondaryColor = primaryGreen;
  static const Color successColor = primaryGreen;
  static const Color milkyWhite = Color(0xFFFCF9F2); // Milky cream white
  static const Color backgroundColor = milkyWhite;
  static const Color premiumBg = milkyWhite;
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE94560);

  // Gradients (Updating to be subtler or removing where needed)
  static const Gradient primaryGradient = LinearGradient(
    colors: [milkyWhite, milkyWhite], // Flattened to color
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primaryGreen, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient softMedicalGradient = LinearGradient(
    colors: [Color(0xFFFDFCFB), Color(0xFFF2F2F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: milkyWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkBlue,
      primary: darkBlue,
      secondary: primaryGreen,
      surface: surfaceColor,
      error: errorColor,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkBlue,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBlue,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold, // Bold headings as requested
        color: darkBlue,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkBlue,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: darkBlue,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        color: darkBlue.withValues(alpha: 0.8),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
    ),
  );
}
