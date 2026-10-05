import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App ThemeData configuration for SehatCoach exclusively using:
/// 1. Inter (Body, Buttons, Labels, Inputs)
/// 2. Dela Gothic One (Titles, Headings, Display text)
class AppTheme {
  static ThemeData get lightTheme {
    final TextTheme baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.graphiteYellow,
        onSecondary: AppColors.medicalBlue,
        surface: AppColors.surface,
        onSurface: AppColors.medicalBlue,
        error: AppColors.errorRed,
        onError: AppColors.white,
        outline: AppColors.border,
      ),

      // AppBar Theme with Dela Gothic One title
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.medicalBlue),
        titleTextStyle: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 18,
        ),
      ),

      // Card Theme Data
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 2,
        shadowColor: AppColors.medicalBlue.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),

      // Button Themes using Inter
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.graphiteYellow,
          foregroundColor: AppColors.medicalBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),

      // Input Decoration Theme using Inter
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),

      // Unified Text Theme combining Inter (Body/UI) and Dela Gothic One (Headings)
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 26,
        ),
        displaySmall: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 22,
        ),
        headlineLarge: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 24,
        ),
        headlineMedium: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 20,
        ),
        headlineSmall: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 18,
        ),
        titleLarge: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 16,
        ),
        titleSmall: GoogleFonts.delaGothicOne(
          color: AppColors.medicalBlue,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

