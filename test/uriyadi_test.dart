import 'package:flutter_test/flutter_test.dart';
import 'package:kalikoot/core/models/difficulty.dart';
import 'package:kalikoot/core/models/game_mode.dart';
import 'package:kalikoot/games/uriyadi/engine/uriyadi_engine.dart';
import 'package:kalikoot/games/uriyadi/engine/uriyadi_state.dart';

void main() {
  group('UriyadiEngine Unit Tests', () {
    test('Initializes with default clean ready state', () {
      final engine = UriyadiEngine();
      expect(engine.state, equals(UriyadiState.ready));
      expect(engine.player1Score, equals(0));
      expect(engine.player2Score, equals(0));
      expect(engine.player1Attempts, equals(0));
      expect(engine.currentTurn, equals(1));
      expect(engine.isMatchOver, isFalse);
    });

    test('Timing accuracy calculation maps angle deviation to correct HitQuality', () {
      final engine = UriyadiEngine(difficulty: Difficulty.medium);
      engine.startRound();

      // At t = 0, sin(0) = 0, angle is exactly 0.0 (Dead center) -> Perfect
      final qualityAtCenter = engine.registerHit(0.0);
      expect(qualityAtCenter, equals(HitQuality.perfect));
      expect(qualityAtCenter!.points, equals(100));
      expect(engine.player1Score, equals(100));
    });

    test('HitQuality points match specifications', () {
      expect(HitQuality.perfect.points, equals(100));
      expect(HitQuality.great.points, equals(70));
      expect(HitQuality.good.points, equals(40));
      expect(HitQuality.miss.points, equals(0));
    });

    test('Duplicate tap protection ignores taps while not in swinging state', () {
      final engine = UriyadiEngine();
      // In ready state, registerHit should return null
      final hitInReady = engine.registerHit(0.0);
      expect(hitInReady, isNull);
      expect(engine.player1Score, equals(0));

      // Start round -> state is swinging
      engine.startRound();
      final validHit = engine.registerHit(0.0);
      expect(validHit, isNotNull);
      expect(engine.state, equals(UriyadiState.hitResult));

      // Rapid consecutive tap while in hitResult must be rejected
      final duplicateTap = engine.registerHit(0.0);
      expect(duplicateTap, isNull);
      expect(engine.player1Score, equals(100)); // Still 100, no duplicate score
    });

    test('Attempt limits enforce 5 attempts in Single-Player', () {
      final engine = UriyadiEngine(mode: GameMode.singlePlayer, maxAttemptsPerPlayer: 5);

      for (int i = 0; i < 5; i++) {
        expect(engine.isMatchOver, isFalse);
        engine.startRound();
        engine.registerHit(0.0);
        engine.advanceTurn();
      }

      expect(engine.player1Attempts, equals(5));
      expect(engine.isMatchOver, isTrue);
      expect(engine.state, equals(UriyadiState.roundComplete));
    });

    test('Two-Player mode alternates turns between Player 1 and Player 2', () {
      final engine = UriyadiEngine(mode: GameMode.twoPlayer, maxAttemptsPerPlayer: 2);

      // Turn 1: P1
      expect(engine.currentTurn, equals(1));
      engine.startRound();
      engine.registerHit(0.0); // P1 gets 100 pts
      engine.advanceTurn();

      // Turn 2: P2
      expect(engine.currentTurn, equals(2));
      engine.startRound();
      engine.registerHit(0.0); // P2 gets 100 pts
      engine.advanceTurn();

      // Turn 3: P1
      expect(engine.currentTurn, equals(1));
      engine.startRound();
      engine.registerHit(0.0);
      engine.advanceTurn();

      // Turn 4: P2
      expect(engine.currentTurn, equals(2));
      engine.startRound();
      engine.registerHit(0.0);
      engine.advanceTurn();

      // Both completed 2 attempts
      expect(engine.isMatchOver, isTrue);
      expect(engine.player1Score, equals(200));
      expect(engine.player2Score, equals(200));
    });

    test('Difficulty affects swing angular speed and frequency', () {
      final easy = UriyadiEngine(difficulty: Difficulty.easy);
      final hard = UriyadiEngine(difficulty: Difficulty.hard);

      // Evaluate angle at small t = 0.2s
      final angleEasy = easy.calculateAngle(0.2);
      final angleHard = hard.calculateAngle(0.2);

      // Hard moves faster and reaches higher angular displacement sooner
      expect(angleHard.abs(), greaterThan(angleEasy.abs()));
    });

    test('Reset restores engine to initial pristine state', () {
      final engine = UriyadiEngine();
      engine.startRound();
      engine.registerHit(0.0);
      expect(engine.player1Score, greaterThan(0));

      engine.reset();
      expect(engine.player1Score, equals(0));
      expect(engine.player1Attempts, equals(0));
      expect(engine.state, equals(UriyadiState.ready));
      expect(engine.lastHitQuality, isNull);
    });
  });
}
