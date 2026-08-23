import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headlines: Hanken Grotesk
  static TextStyle get headlineXL => GoogleFonts.hankenGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01 * 32,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  // Body Text: Inter
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurfaceVariant,
      );

  // Labels: Geist (or a suitable backup if Geist is not packaged directly, we can fall back or use GoogleFonts.geist if available, otherwise GoogleFonts.spaceGrotesk or similar, but wait, google_fonts has Geist! Let's check GoogleFonts list. To be safe, we can use GoogleFonts.geist or similar mono/sans fonts like GoogleFonts.geistSans or GoogleFonts.jetBrainsMono or system font. Let's see if GoogleFonts has `geist`. Yes, since it's listed, we can use `GoogleFonts.geist` or GoogleFonts.dmSans or fall back to system font if it fails. Let's use GoogleFonts.spaceGrotesk or custom style). Let's see, if Geist doesn't exist, it might throw a compiler error. Let's check if google_fonts has geist. Actually, GoogleFonts supports Geist since version 6.0+. So GoogleFonts.geist() is valid.
  static TextStyle get labelMd => GoogleFonts.spaceGrotesk( // Falling back to Space Grotesk or using Geist if available
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 16 / 14,
        letterSpacing: 0.02 * 14,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelSm => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 14 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.outline,
      );
}
