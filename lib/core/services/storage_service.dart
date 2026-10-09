import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence service for KaliKoot.
/// Stores audio preferences, haptics, high scores, and match statistics.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // In-memory fallbacks ensuring rock-solid offline behavior even before async init
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  final Map<String, int> _highScores = {};
  final Map<String, int> _stats = {};

  static const String keySound = 'kalikoot_sound_enabled';
  static const String keyHaptic = 'kalikoot_haptic_enabled';
  static const String prefixHighScore = 'kalikoot_high_score_';
  static const String prefixStat = 'kalikoot_stat_';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _soundEnabled = _prefs?.getBool(keySound) ?? true;
      _hapticEnabled = _prefs?.getBool(keyHaptic) ?? true;
    } catch (e) {
      debugPrint('SharedPreferences init fallback: $e');
    }
  }

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs?.setBool(keySound, enabled);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    await _prefs?.setBool(keyHaptic, enabled);
  }

  int getHighScore(String gameKey) {
    if (_prefs != null) {
      return _prefs!.getInt('$prefixHighScore$gameKey') ?? _highScores[gameKey] ?? 0;
    }
    return _highScores[gameKey] ?? 0;
  }

  Future<bool> saveHighScoreIfBest(String gameKey, int score) async {
    final currentBest = getHighScore(gameKey);
    if (score > currentBest) {
      _highScores[gameKey] = score;
      await _prefs?.setInt('$prefixHighScore$gameKey', score);
      return true;
    }
    return false;
  }

  int getStat(String statKey) {
    if (_prefs != null) {
      return _prefs!.getInt('$prefixStat$statKey') ?? _stats[statKey] ?? 0;
    }
    return _stats[statKey] ?? 0;
  }

  Future<void> incrementStat(String statKey) async {
    final current = getStat(statKey);
    final updated = current + 1;
    _stats[statKey] = updated;
    await _prefs?.setInt('$prefixStat$statKey', updated);
  }

  Future<void> resetAllStats() async {
    _highScores.clear();
    _stats.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final k in keys) {
        if (k.startsWith(prefixHighScore) || k.startsWith(prefixStat)) {
          await _prefs!.remove(k);
        }
      }
    }
  }
}
