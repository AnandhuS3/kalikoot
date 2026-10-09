import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/difficulty.dart';
import 'goli_physics.dart';

class GoliAI {
  static final math.Random _random = math.Random();

  /// Calculates a shot velocity vector for the computer player
  static Offset calculateShot({
    required Marble shooter,
    required List<Marble> targets,
    required Offset scoringZoneCenter,
    required Difficulty difficulty,
    required Rect arenaBounds,
  }) {
    final activeTargets = targets.where((m) => !m.isScored).toList();
    if (activeTargets.isEmpty) {
      // Default harmless shot towards center
      return const Offset(0, -10.0);
    }

    switch (difficulty) {
      case Difficulty.easy:
        return _calculateEasyShot(shooter, activeTargets);
      case Difficulty.medium:
        return _calculateMediumShot(shooter, activeTargets, scoringZoneCenter);
      case Difficulty.hard:
        return _calculateHardShot(shooter, activeTargets, scoringZoneCenter);
    }
  }

  static Offset _calculateEasyShot(Marble shooter, List<Marble> targets) {
    // Pick random target
    final target = targets[_random.nextInt(targets.length)];
    final toTarget = target.position - shooter.position;
    final baseAngle = math.atan2(toTarget.dy, toTarget.dx);

    // Large angle error +/- 35 degrees
    final errorAngle = (_random.nextDouble() - 0.5) * (70 * math.pi / 180);
    final finalAngle = baseAngle + errorAngle;

    // Inconsistent power
    final speed = 8.0 + _random.nextDouble() * 12.0;
    return Offset(speed * math.cos(finalAngle), speed * math.sin(finalAngle));
  }

  static Offset _calculateMediumShot(
    Marble shooter,
    List<Marble> targets,
    Offset scoringZone,
  ) {
    // Pick target closest to scoring zone
    targets.sort((a, b) =>
        (a.position - scoringZone).distanceSquared.compareTo(
              (b.position - scoringZone).distanceSquared,
            ));
    final target = targets.first;

    final toTarget = target.position - shooter.position;
    final baseAngle = math.atan2(toTarget.dy, toTarget.dx);

    // Modest error +/- 8 degrees
    final errorAngle = (_random.nextDouble() - 0.5) * (16 * math.pi / 180);
    final finalAngle = baseAngle + errorAngle;

    final dist = toTarget.distance;
    final speed = (dist * 0.08).clamp(12.0, 24.0);
    return Offset(speed * math.cos(finalAngle), speed * math.sin(finalAngle));
  }

  static Offset _calculateHardShot(
    Marble shooter,
    List<Marble> targets,
    Offset scoringZone,
  ) {
    Marble? bestTarget;
    Offset? bestAimPoint;
    double bestQuality = -1;

    for (final target in targets) {
      // Vector from target to scoring zone
      final toZone = scoringZone - target.position;
      final zoneDist = toZone.distance;
      if (zoneDist < 0.001) continue;

      final zoneDir = toZone / zoneDist;

      // Ghost-ball center: where shooter must be to knock target towards scoring zone
      final combinedRadius = shooter.radius + target.radius;
      final ghostCenter = target.position - zoneDir * combinedRadius;

      // Line of sight from shooter to ghost center
      final toGhost = ghostCenter - shooter.position;
      final ghostDist = toGhost.distance;

      // Quality metric: closer ghost target with direct angle
      final quality = 1000.0 / (ghostDist + zoneDist);
      if (quality > bestQuality) {
        bestQuality = quality;
        bestTarget = target;
        bestAimPoint = ghostCenter;
      }
    }

    if (bestAimPoint == null || bestTarget == null) {
      return _calculateMediumShot(shooter, targets, scoringZone);
    }

    final toGhost = bestAimPoint - shooter.position;
    final baseAngle = math.atan2(toGhost.dy, toGhost.dx);

    // Very tight expert tolerance +/- 1.5 degrees
    final errorAngle = (_random.nextDouble() - 0.5) * (3.0 * math.pi / 180);
    final finalAngle = baseAngle + errorAngle;

    // Calibrated impulse based on total trajectory length
    final totalDist = toGhost.distance + (scoringZone - bestTarget.position).distance;
    final speed = (totalDist * 0.09).clamp(15.0, 28.0);

    return Offset(speed * math.cos(finalAngle), speed * math.sin(finalAngle));
  }
}
