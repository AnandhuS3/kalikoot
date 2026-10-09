import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Difficulty levels for single-player computer opponents.
enum Difficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Gentle pacing and forgiving opponent actions. Great for relaxed play.';
      case Difficulty.medium:
        return 'Balanced timing and observant computer tactics. A fair casual match.';
      case Difficulty.hard:
        return 'Demanding precision and adaptive strategy. The ultimate test of skill.';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return AppColors.green;
      case Difficulty.medium:
        return AppColors.yellow;
      case Difficulty.hard:
        return AppColors.coral;
    }
  }

  /// 0.0 for Easy, 0.5 for Medium, 1.0 for Hard for slider mapping.
  double get sliderValue {
    switch (this) {
      case Difficulty.easy:
        return 0.0;
      case Difficulty.medium:
        return 0.5;
      case Difficulty.hard:
        return 1.0;
    }
  }

  static Difficulty fromSliderValue(double value) {
    if (value < 0.25) return Difficulty.easy;
    if (value < 0.75) return Difficulty.medium;
    return Difficulty.hard;
  }
}
