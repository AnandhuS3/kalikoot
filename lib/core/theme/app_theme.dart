import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Central theme configuration for KaliKoot.
class AppTheme {
  AppTheme._();

  static const double cardBorderRadius = 24.0;
  static const double buttonBorderRadius = 18.0;
  static const double pillBorderRadius = 30.0;
  static const double cardBorderWidth = 3.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontBody,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryNavy,
        onPrimary: AppColors.white,
        secondary: AppColors.coral,
        onSecondary: AppColors.white,
        tertiary: AppColors.cyan,
        onTertiary: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
        error: AppColors.coral,
        onError: AppColors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryNavy, size: 28),
      ),
    );
  }

  /// BoxDecoration for prominent game cards with thick navy borders and subtle drop shadow.
  static BoxDecoration chunkyCardDecoration({
    Color backgroundColor = AppColors.white,
    Color borderColor = AppColors.primaryNavy,
    double radius = cardBorderRadius,
    double borderWidth = cardBorderWidth,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: borderColor.withAlpha(50),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ]
          : null,
    );
  }
}
