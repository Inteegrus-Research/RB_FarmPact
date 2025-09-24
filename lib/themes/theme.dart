import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Earthy and trustworthy
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);

  // Risk Colors
  static const Color lowRisk = Color(0xFF4CAF50);
  static const Color mediumRisk = Color(0xFFFFC107);
  static const Color highRisk = Color(0xFFD32F2F);

  // Additional colors for UI elements
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color shadowColor = Color(0x1A000000);

  // Typography
  static TextTheme get textTheme => TextTheme(
        // Headings
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          height: 1.3,
        ),

        // Titles
        titleLarge: GoogleFonts.poppins(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
          height: 1.4,
        ),

        // Body text
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
          height: 1.4,
        ),

        // Labels
        labelLarge: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
          height: 1.4,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,

        // Color scheme
        colorScheme: const ColorScheme.light(
          primary: primaryGreen,
          secondary: primaryGreen,
          surface: cardBackground,
          background: backgroundColor,
          error: highRisk,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: primaryTextColor,
          onBackground: primaryTextColor,
          onError: Colors.white,
        ),

        // Scaffold background
        scaffoldBackgroundColor: backgroundColor,

        // Typography
        textTheme: textTheme,

        // AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 24.0,
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          color: cardBackground,
          elevation: 4.0,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(double.infinity, 56.0),
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryGreen,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: dividerColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: dividerColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: primaryGreen, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: highRisk, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: highRisk, width: 2.0),
          ),
          labelStyle: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          ),
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: primaryTextColor,
          size: 24.0,
        ),

        // Divider theme
        dividerTheme: const DividerThemeData(
          color: dividerColor,
          thickness: 1.0,
          space: 1.0,
        ),
      );

  // Risk level colors helper
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return lowRisk;
      case 'medium':
      case 'moderate':
        return mediumRisk;
      case 'high':
        return highRisk;
      default:
        return mediumRisk;
    }
  }

  // Get risk color by score (0-100)
  static Color getRiskColorByScore(double score) {
    if (score <= 30) {
      return lowRisk;
    } else if (score <= 70) {
      return mediumRisk;
    } else {
      return highRisk;
    }
  }

  // Get risk level text by score
  static String getRiskLevelText(double score) {
    if (score <= 30) {
      return 'Low Risk';
    } else if (score <= 70) {
      return 'Moderate Risk';
    } else {
      return 'High Risk';
    }
  }
}
