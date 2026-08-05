import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle pageTitle({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
      );

  static TextStyle sectionTitle({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
      );

  static TextStyle sectionDescription({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
      );

  static TextStyle body({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
      );

  static TextStyle bodyMedium({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
      );

  static TextStyle tableHeading({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 1.2,
        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
      );

  static TextStyle caption({bool isDark = false}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
      );

  static TextStyle amountPositive() => GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        height: 1.5,
        color: AppColors.success,
      );

  static TextStyle amountNegative() => GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        height: 1.5,
        color: AppColors.danger,
      );

  static TextStyle receiptCode({bool isDark = false}) => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        height: 1.4,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
      );
}
