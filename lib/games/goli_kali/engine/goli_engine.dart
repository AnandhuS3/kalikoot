import 'package:flutter/material.dart';
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_mode.dart';
import '../../../core/theme/app_colors.dart';
import 'goli_ai.dart';
import 'goli_physics.dart';

class GoliEngine {
  final Difficulty difficulty;
  final GameMode mode;
  final int maxShotsPerPlayer;

  Rect arenaBounds = Rect.zero;
  Offset scoringZoneCenter = Offset.zero;
  double scoringZoneRadius = 46.0;

  final List<Marble> marbles = [];
  late Marble shooterMarble;

  int _player1Score = 0;
  int _player2Score = 0;
  int _player1Shots = 0;
  int _player2Shots = 0;
  int _currentTurn = 1; // 1 = P1, 2 = P2 or AI
  bool _isSimulating = false;

  GoliEngine({
    this.difficulty = Difficulty.medium,
    this.mode = GameMode.singlePlayer,
    this.maxShotsPerPlayer = 5,
  });

  // Getters
  int get player1Score => _player1Score;
  int get player2Score => _player2Score;
  int get player1Shots => _player1Shots;
  int get player2Shots => _player2Shots;
  int get currentTurn => _currentTurn;
  bool get isSimulating => _isSimulating;

  bool get isMatchOver {
    final targetsRemaining = marbles.where((m) => !m.isShooter && !m.isScored).length;
    if (targetsRemaining == 0) return true;

    if (mode == GameMode.singlePlayer) {
      return _player1Shots >= maxShotsPerPlayer && _player2Shots >= maxShotsPerPlayer;
    } else {
      return _player1Shots >= maxShotsPerPlayer && _player2Shots >= maxShotsPerPlayer;
    }
  }

  void initializeArena(Rect bounds) {
    arenaBounds = bounds;
    scoringZoneCenter = Offset(bounds.center.dx, bounds.center.dy - 30);
    resetMarbles();
  }

  void resetMarbles() {
    marbles.clear();
    final cx = arenaBounds.center.dx;
    final cy = arenaBounds.center.dy;

    // Shooter marble at bottom shooting line
    shooterMarble = Marble(
      id: 0,
      position: Offset(cx, arenaBounds.bottom - 45),
      radius: 17.0,
      color: AppColors.cyan,
      swirlColor: AppColors.yellow,
      isShooter: true,
    );
    marbles.add(shooterMarble);

    // 4 Target Marbles around the scoring circle
    final targetColors = [
      (AppColors.coral, AppColors.white),
      (AppColors.green, AppColors.coral),
      (AppColors.purple, AppColors.cyan),
      (AppColors.yellow, AppColors.coral),
    ];

    final offsets = [
      Offset(cx - 38, cy - 80),
      Offset(cx + 38, cy - 80),
      Offset(cx - 45, cy + 20),
      Offset(cx + 45, cy + 20),
    ];

    for (int i = 0; i < offsets.length; i++) {
      marbles.add(Marble(
        id: i + 1,
        position: offsets[i],
        radius: 15.0,
        color: targetColors[i].$1,
        swirlColor: targetColors[i].$2,
        isShooter: false,
      ));
    }

    _isSimulating = false;
  }

  /// Fires the shooter marble with the given impulse vector
  bool shoot(Offset impulse) {
    if (_isSimulating || isMatchOver) return false;

    shooterMarble.velocity = impulse;
    _isSimulating = true;
    return true;
  }

  /// Triggers AI shot calculation and impulse
  Offset executeAIShot() {
    final targets = marbles.where((m) => !m.isShooter).toList();
    final impulse = GoliAI.calculateShot(
      shooter: shooterMarble,
      targets: targets,
      scoringZoneCenter: scoringZoneCenter,
      difficulty: difficulty,
      arenaBounds: arenaBounds,
    );
    shoot(impulse);
    return impulse;
  }

  /// Steps physics and checks scoring. Returns true when all marbles have stopped
  bool updateSimulation() {
    if (!_isSimulating) return false;

    GoliPhysics.update(marbles, arenaBounds);

    // Check target marbles entering the scoring zone
    for (final m in marbles) {
      if (!m.isShooter && !m.isScored) {
        final dist = (m.position - scoringZoneCenter).distance;
        if (dist <= scoringZoneRadius) {
          m.isScored = true;
          m.velocity = Offset.zero;

          // Award points to active player
          if (_currentTurn == 1) {
            _player1Score += 100;
          } else {
            _player2Score += 100;
          }
        }
      }
    }

    // Check if movement is completely finished
    if (GoliPhysics.areAllMarblesStopped(marbles)) {
      _isSimulating = false;
      _onShotComplete();
      return true;
    }

    return false;
  }

  void _onShotComplete() {
    // Record shot count
    if (_currentTurn == 1) {
      _player1Shots++;
    } else {
      _player2Shots++;
    }

    // Reset shooter marble back to base line
    shooterMarble.position = Offset(
      arenaBounds.center.dx,
      arenaBounds.bottom - 45,
    );
    shooterMarble.velocity = Offset.zero;

    // Switch turns if match is not over
    if (!isMatchOver) {
      _currentTurn = _currentTurn == 1 ? 2 : 1;
    }
  }

  void reset() {
    _player1Score = 0;
    _player2Score = 0;
    _player1Shots = 0;
    _player2Shots = 0;
    _currentTurn = 1;
    _isSimulating = false;
    resetMarbles();
  }
}
