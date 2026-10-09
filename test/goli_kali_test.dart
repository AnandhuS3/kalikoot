import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalikoot/core/models/difficulty.dart';
import 'package:kalikoot/core/models/game_mode.dart';
import 'package:kalikoot/games/goli_kali/engine/goli_ai.dart';
import 'package:kalikoot/games/goli_kali/engine/goli_engine.dart';
import 'package:kalikoot/games/goli_kali/engine/goli_physics.dart';

void main() {
  group('Goli Kali Physics & Engine Unit Tests', () {
    test('Circle-circle elastic collision conserves momentum and separates overlapping bodies', () {
      final m1 = Marble(
        id: 1,
        position: const Offset(100, 100),
        velocity: const Offset(10, 0),
        radius: 15,
        color: Colors.blue,
        swirlColor: Colors.yellow,
      );

      final m2 = Marble(
        id: 2,
        position: const Offset(120, 100),
        velocity: Offset.zero,
        radius: 15,
        color: Colors.red,
        swirlColor: Colors.white,
      );

      final bounds = const Rect.fromLTWH(0, 0, 500, 500);
      // Run single sub-step update
      GoliPhysics.update([m1, m2], bounds, subSteps: 1);

      // m1 should transfer momentum along the collision normal to m2
      expect(m2.velocity.dx, greaterThan(0));
      // Distance between centers should be at least sum of radii
      expect((m2.position - m1.position).distance, greaterThanOrEqualTo(29.0));
    });

    test('Wall collision reflects velocity with restitution coefficient and keeps within bounds', () {
      final bounds = const Rect.fromLTWH(0, 0, 200, 200);
      final m = Marble(
        id: 1,
        position: const Offset(195, 100),
        velocity: const Offset(20, 0), // Moving right towards wall at x=200
        radius: 10,
        color: Colors.blue,
        swirlColor: Colors.yellow,
      );

      GoliPhysics.update([m], bounds, subSteps: 1);

      // Must be kept inside bounds (position <= 190)
      expect(m.position.dx, lessThanOrEqualTo(190.0));
      // Velocity must be reflected (dx < 0) and dampened
      expect(m.velocity.dx, lessThan(0));
      expect(m.velocity.dx.abs(), lessThan(20.0));
    });

    test('Friction reduces marble velocity over time down to stop threshold', () {
      final bounds = const Rect.fromLTWH(0, 0, 500, 500);
      final m = Marble(
        id: 1,
        position: const Offset(250, 250),
        velocity: const Offset(3.0, 0), // Slow moving marble
        radius: 10,
        color: Colors.blue,
        swirlColor: Colors.yellow,
      );

      for (int i = 0; i < 50; i++) {
        GoliPhysics.update([m], bounds, subSteps: 1);
      }

      // Should snap to Offset.zero below cutoff threshold
      expect(m.velocity, equals(Offset.zero));
      expect(m.isMoving, isFalse);
    });

    test('Target marble entering scoring zone awards points and marks isScored', () {
      final engine = GoliEngine();
      engine.initializeArena(const Rect.fromLTWH(0, 0, 300, 500));

      // Place target marble directly inside scoring zone
      final target = engine.marbles.firstWhere((m) => !m.isShooter);
      target.position = engine.scoringZoneCenter;

      engine.shoot(const Offset(0, -10));
      expect(engine.isSimulating, isTrue);

      engine.updateSimulation();

      expect(target.isScored, isTrue);
      expect(engine.player1Score, equals(100));
    });

    test('Invalid shot rejected while simulation is already active', () {
      final engine = GoliEngine();
      engine.initializeArena(const Rect.fromLTWH(0, 0, 300, 500));

      final firstShot = engine.shoot(const Offset(0, -15));
      expect(firstShot, isTrue);
      expect(engine.isSimulating, isTrue);

      // Attempting to shoot again while simulating must be rejected
      final secondShot = engine.shoot(const Offset(5, -10));
      expect(secondShot, isFalse);
    });

    test('AI calculates legal non-zero shot vectors across Easy, Medium, and Hard', () {
      final bounds = const Rect.fromLTWH(0, 0, 300, 500);
      final shooter = Marble(
        id: 0,
        position: const Offset(150, 450),
        radius: 15,
        color: Colors.cyan,
        swirlColor: Colors.yellow,
        isShooter: true,
      );

      final targets = [
        Marble(
          id: 1,
          position: const Offset(150, 200),
          radius: 15,
          color: Colors.red,
          swirlColor: Colors.white,
        ),
      ];

      for (final diff in Difficulty.values) {
        final shot = GoliAI.calculateShot(
          shooter: shooter,
          targets: targets,
          scoringZoneCenter: const Offset(150, 220),
          difficulty: diff,
          arenaBounds: bounds,
        );

        expect(shot.distance, greaterThan(5.0));
        expect(shot.dy, lessThan(0)); // Moving upward towards target
      }
    });

    test('Two-Player mode alternates turns after shots complete', () {
      final engine = GoliEngine(mode: GameMode.twoPlayer);
      engine.initializeArena(const Rect.fromLTWH(0, 0, 300, 500));

      expect(engine.currentTurn, equals(1));
      engine.shoot(const Offset(0, -10));

      // Simulate until marbles stop
      while (engine.isSimulating) {
        engine.updateSimulation();
      }

      // Should now be Turn 2 (Player 2)
      expect(engine.currentTurn, equals(2));
      expect(engine.player1Shots, equals(1));
    });
  });
}
