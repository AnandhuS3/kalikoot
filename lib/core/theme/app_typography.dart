import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central typography styles for KaliKoot.
/// Uses bold, confident sans-serif typography with high readability.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'sans-serif-rounded';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.primaryNavy,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: AppColors.primaryNavy,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryNavy,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryNavy,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedText,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    letterSpacing: 0.8,
  );

  static const TextStyle pillLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle scoreNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    height: 1.0,
  );
}
