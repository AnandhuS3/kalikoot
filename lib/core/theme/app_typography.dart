import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central typography styles for KaliKoot.
/// Uses bundled 'LilitaOne' for punchy, playful game headings and 'Fredoka' for rounded body text.
class AppTypography {
  AppTypography._();

  static const String fontDisplay = 'LilitaOne';
  static const String fontTitle = 'LilitaOne';
  static const String fontBody = 'Fredoka';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 34,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryNavy,
    letterSpacing: 0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 26,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryNavy,
    letterSpacing: 0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 22,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryNavy,
    letterSpacing: 0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryNavy,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedText,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    letterSpacing: 1.0,
  );

  static const TextStyle pillLabel = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    letterSpacing: 0.8,
  );

  static const TextStyle scoreNumber = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    height: 1.0,
  );
}
