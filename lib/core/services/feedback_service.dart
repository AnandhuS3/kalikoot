import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Lightweight, offline audio and haptic feedback service for KaliKoot.
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final StorageService _storage = StorageService();

  /// Subtle UI tap sound and tactile response
  void playTap() {
    if (_storage.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_storage.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Successful action / hit sound and impact
  void playHit() {
    if (_storage.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_storage.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Miss or failure cue
  void playMiss() {
    if (_storage.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (_storage.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Round completion feedback
  void playRoundComplete() {
    if (_storage.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_storage.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Match win celebration
  void playVictory() {
    if (_storage.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_storage.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void triggerHapticLight() {
    if (_storage.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void triggerHapticMedium() {
    if (_storage.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void triggerHapticHeavy() {
    if (_storage.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
