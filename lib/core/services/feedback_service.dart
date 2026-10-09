import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Full-featured audio and haptic feedback service for KaliKoot.
/// Plays real offline bundled WAV sound effects via AudioPlayer with fallback support.
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final StorageService _storage = StorageService();
  AudioPlayer? _player;

  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> _playSound(String assetName) async {
    if (!_storage.soundEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$assetName'));
    } catch (_) {
      // In headless test environments or when audio channels aren't bound
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Tactile button tap & UI click
  void playTap() {
    _playSound('tap.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Successful hit / pot smash
  void playHit() {
    _playSound('hit.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Miss / whoosh slide
  void playMiss() {
    _playSound('miss.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Glass marble collision clack
  void playMarble() {
    _playSound('marble.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Martial weapon clash & spark
  void playClash() {
    _playSound('clash.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Round completion chime
  void playRoundComplete() {
    _playSound('complete.wav');
    if (_storage.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Match victory celebration fanfare
  void playVictory() {
    _playSound('victory.wav');
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
