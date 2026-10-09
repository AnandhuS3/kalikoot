import 'dart:math' as math;
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_mode.dart';
import 'uriyadi_state.dart';

class UriyadiEngine {
  final Difficulty difficulty;
  final GameMode mode;
  final int maxAttemptsPerPlayer;

  UriyadiState _state = UriyadiState.ready;
  int _player1Score = 0;
  int _player2Score = 0;
  int _player1Attempts = 0;
  int _player2Attempts = 0;
  int _currentTurn = 1; // 1 = Player 1, 2 = Player 2
  HitQuality? _lastHitQuality;

  UriyadiEngine({
    this.difficulty = Difficulty.medium,
    this.mode = GameMode.singlePlayer,
    this.maxAttemptsPerPlayer = 5,
  });

  // Getters
  UriyadiState get state => _state;
  int get player1Score => _player1Score;
  int get player2Score => _player2Score;
  int get player1Attempts => _player1Attempts;
  int get player2Attempts => _player2Attempts;
  int get currentTurn => _currentTurn;
  HitQuality? get lastHitQuality => _lastHitQuality;

  bool get isMatchOver {
    if (mode == GameMode.singlePlayer) {
      return _player1Attempts >= maxAttemptsPerPlayer;
    } else {
      return _player1Attempts >= maxAttemptsPerPlayer &&
          _player2Attempts >= maxAttemptsPerPlayer;
    }
  }

  int get currentAttemptNumber {
    if (_currentTurn == 1) {
      return _player1Attempts + 1;
    } else {
      return _player2Attempts + 1;
    }
  }

  void startRound() {
    if (!isMatchOver) {
      _state = UriyadiState.swinging;
      _lastHitQuality = null;
    } else {
      _state = UriyadiState.roundComplete;
    }
  }

  /// Calculates swinging angle theta (in radians) at time t (in seconds).
  double calculateAngle(double t) {
    switch (difficulty) {
      case Difficulty.easy:
        // Slow and predictable single harmonic
        const freq = 0.45;
        const amp = 0.70;
        return amp * math.sin(2 * math.pi * freq * t);

      case Difficulty.medium:
        // Faster swing with mild secondary harmonic
        const freq = 0.65;
        const amp = 0.85;
        return amp * (math.sin(2 * math.pi * freq * t) +
            0.12 * math.sin(4 * math.pi * freq * t));

      case Difficulty.hard:
        // Demanding swing with multi-frequency compound harmonics
        const freq = 0.95;
        const amp = 1.05;
        return amp * (0.80 * math.sin(2 * math.pi * freq * t) +
            0.20 * math.sin(6 * math.pi * freq * t + (math.pi / 4)));
    }
  }

  /// Evaluates timing accuracy and awards points based on current pendulum angle.
  /// Ignores duplicate taps if not currently in swinging state.
  HitQuality? registerHit(double t) {
    if (_state != UriyadiState.swinging) {
      // Duplicate tap protection
      return null;
    }

    final angle = calculateAngle(t);
    final absAngle = angle.abs();

    // Determine hit quality based on difficulty thresholds
    HitQuality quality;
    switch (difficulty) {
      case Difficulty.easy:
        if (absAngle < 0.12) {
          quality = HitQuality.perfect;
        } else if (absAngle < 0.32) {
          quality = HitQuality.great;
        } else if (absAngle < 0.58) {
          quality = HitQuality.good;
        } else {
          quality = HitQuality.miss;
        }
        break;

      case Difficulty.medium:
        if (absAngle < 0.08) {
          quality = HitQuality.perfect;
        } else if (absAngle < 0.22) {
          quality = HitQuality.great;
        } else if (absAngle < 0.44) {
          quality = HitQuality.good;
        } else {
          quality = HitQuality.miss;
        }
        break;

      case Difficulty.hard:
        if (absAngle < 0.06) {
          quality = HitQuality.perfect;
        } else if (absAngle < 0.16) {
          quality = HitQuality.great;
        } else if (absAngle < 0.34) {
          quality = HitQuality.good;
        } else {
          quality = HitQuality.miss;
        }
        break;
    }

    _lastHitQuality = quality;
    final points = quality.points;

    if (_currentTurn == 1) {
      _player1Score += points;
      _player1Attempts++;
    } else {
      _player2Score += points;
      _player2Attempts++;
    }

    _state = UriyadiState.hitResult;
    return quality;
  }

  /// Advances turn and prepares next attempt or completes match.
  void advanceTurn() {
    if (isMatchOver) {
      _state = UriyadiState.roundComplete;
      return;
    }

    if (mode == GameMode.twoPlayer) {
      // Alternate between Player 1 and Player 2
      if (_currentTurn == 1) {
        if (_player2Attempts < maxAttemptsPerPlayer) {
          _currentTurn = 2;
        }
      } else {
        if (_player1Attempts < maxAttemptsPerPlayer) {
          _currentTurn = 1;
        }
      }
    }

    _state = UriyadiState.ready;
    _lastHitQuality = null;
  }

  void reset() {
    _state = UriyadiState.ready;
    _player1Score = 0;
    _player2Score = 0;
    _player1Attempts = 0;
    _player2Attempts = 0;
    _currentTurn = 1;
    _lastHitQuality = null;
  }
}
