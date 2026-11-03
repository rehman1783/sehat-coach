import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized Typography System for Sehat Coach.
/// Exclusively uses two font families across the entire application:
/// 1. [Dela Gothic One] - For display headings, main titles, app branding, section headers.
/// 2. [Inter] - For body text, subtitles, UI elements, buttons, input fields, labels.
class AppTypography {
  // --- Dela Gothic One Styles (Headings, Display & Section Titles) ---

  static TextStyle delaGothic({
    double fontSize = 20,
    Color color = AppColors.medicalBlue,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.delaGothicOne(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle displayLarge({Color color = AppColors.medicalBlue}) {
    return GoogleFonts.delaGothicOne(fontSize: 32, color: color, height: 1.2);
  }

  static TextStyle displayMedium({Color color = AppColors.medicalBlue}) {
    return GoogleFonts.delaGothicOne(fontSize: 26, color: color, height: 1.25);
  }

  static TextStyle headlineMedium({Color color = AppColors.medicalBlue}) {
    return GoogleFonts.delaGothicOne(fontSize: 22, color: color, height: 1.3);
  }

  static TextStyle titleLarge({Color color = AppColors.medicalBlue}) {
    return GoogleFonts.delaGothicOne(fontSize: 18, color: color, height: 1.3);
  }

  static TextStyle titleMedium({Color color = AppColors.medicalBlue}) {
    return GoogleFonts.delaGothicOne(fontSize: 16, color: color, height: 1.35);
  }

  // --- Inter Styles (Body, Subtitles, Buttons, Labels) ---

  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle bodyLarge({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: fontWeight,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({
    Color color = AppColors.textSecondary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: fontWeight,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodySmall({
    Color color = AppColors.textSecondary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: fontWeight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle button({
    Color color = AppColors.medicalBlue,
    double fontSize = 15,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.5,
    );
  }

  static TextStyle label({
    Color color = AppColors.textSecondary,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.3,
    );
  }
}
