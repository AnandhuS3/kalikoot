import 'package:flutter/material.dart';

class Marble {
  final int id;
  Offset position;
  Offset velocity;
  final double radius;
  final double mass;
  final Color color;
  final Color swirlColor;
  final bool isShooter;
  bool isScored;

  Marble({
    required this.id,
    required this.position,
    this.velocity = Offset.zero,
    this.radius = 16.0,
    this.mass = 1.0,
    required this.color,
    required this.swirlColor,
    this.isShooter = false,
    this.isScored = false,
  });

  bool get isMoving => velocity.distanceSquared > 4.0; // speed > 2 px/s
}

class GoliPhysics {
  static const double friction = 0.982; // Rolling friction per tick
  static const double wallRestitution = 0.85; // Energy retained after wall bounce
  static const double minVelocityCutoff = 1.8; // Snaps to 0 below this speed

  /// Steps the physics simulation forward by dt
  static void update(
    List<Marble> marbles,
    Rect arenaBounds, {
    int subSteps = 4,
  }) {
    final subDt = 1.0 / subSteps;

    for (int step = 0; step < subSteps; step++) {
      // 1. Position update
      for (final m in marbles) {
        if (m.isScored) continue;
        m.position += m.velocity * subDt;
      }

      // 2. Circle-Circle elastic collisions
      for (int i = 0; i < marbles.length; i++) {
        final m1 = marbles[i];
        if (m1.isScored) continue;

        for (int j = i + 1; j < marbles.length; j++) {
          final m2 = marbles[j];
          if (m2.isScored) continue;

          _resolveCircleCollision(m1, m2);
        }
      }

      // 3. Wall collisions
      for (final m in marbles) {
        if (m.isScored) continue;
        _resolveWallCollision(m, arenaBounds);
      }
    }

    // 4. Apply rolling friction & velocity cutoff
    for (final m in marbles) {
      if (m.isScored) continue;
      m.velocity *= friction;

      if (m.velocity.distance < minVelocityCutoff) {
        m.velocity = Offset.zero;
      }
    }
  }

  static void _resolveCircleCollision(Marble m1, Marble m2) {
    final delta = m2.position - m1.position;
    final dist = delta.distance;
    final minDist = m1.radius + m2.radius;

    if (dist < minDist && dist > 0.001) {
      // Normal unit vector
      final normal = delta / dist;
      // Tangent unit vector
      final tangent = Offset(-normal.dy, normal.dx);

      // Separate overlapping marbles to prevent sticking
      final overlap = 0.5 * (minDist - dist);
      m1.position -= normal * overlap;
      m2.position += normal * overlap;

      // Decompose velocities into normal & tangential components
      final v1n = m1.velocity.dx * normal.dx + m1.velocity.dy * normal.dy;
      final v1t = m1.velocity.dx * tangent.dx + m1.velocity.dy * tangent.dy;
      final v2n = m2.velocity.dx * normal.dx + m2.velocity.dy * normal.dy;
      final v2t = m2.velocity.dx * tangent.dx + m2.velocity.dy * tangent.dy;

      // 1D elastic collision along normal line
      final mSum = m1.mass + m2.mass;
      final newV1n = (v1n * (m1.mass - m2.mass) + 2 * m2.mass * v2n) / mSum;
      final newV2n = (v2n * (m2.mass - m1.mass) + 2 * m1.mass * v1n) / mSum;

      // Reconstruct velocity vectors
      m1.velocity = normal * newV1n + tangent * v1t;
      m2.velocity = normal * newV2n + tangent * v2t;
    }
  }

  static void _resolveWallCollision(Marble m, Rect bounds) {
    // Left
    if (m.position.dx - m.radius < bounds.left) {
      m.position = Offset(bounds.left + m.radius, m.position.dy);
      m.velocity = Offset(-m.velocity.dx * wallRestitution, m.velocity.dy);
    }
    // Right
    if (m.position.dx + m.radius > bounds.right) {
      m.position = Offset(bounds.right - m.radius, m.position.dy);
      m.velocity = Offset(-m.velocity.dx * wallRestitution, m.velocity.dy);
    }
    // Top
    if (m.position.dy - m.radius < bounds.top) {
      m.position = Offset(m.position.dx, bounds.top + m.radius);
      m.velocity = Offset(m.velocity.dx, -m.velocity.dy * wallRestitution);
    }
    // Bottom
    if (m.position.dy + m.radius > bounds.bottom) {
      m.position = Offset(m.position.dx, bounds.bottom - m.radius);
      m.velocity = Offset(m.velocity.dx, -m.velocity.dy * wallRestitution);
    }
  }

  /// Returns true if all marbles have come to a complete stop
  static bool areAllMarblesStopped(List<Marble> marbles) {
    for (final m in marbles) {
      if (!m.isScored && m.isMoving) {
        return false;
      }
    }
    return true;
  }
}
