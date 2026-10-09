import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/goli_physics.dart';

class GoliArenaPainter extends CustomPainter {
  final List<Marble> marbles;
  final Rect arenaBounds;
  final Offset scoringZoneCenter;
  final double scoringZoneRadius;
  final Offset? dragStart;
  final Offset? dragCurrent;
  final bool isAiming;

  GoliArenaPainter({
    required this.marbles,
    required this.arenaBounds,
    required this.scoringZoneCenter,
    required this.scoringZoneRadius,
    this.dragStart,
    this.dragCurrent,
    this.isAiming = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (arenaBounds == Rect.zero) return;

    // 1. Draw Arena Ground
    final groundPaint = Paint()..color = const Color(0xFFF3ECE0);
    final arenaRRect = RRect.fromRectAndRadius(arenaBounds, const Radius.circular(24));
    canvas.drawRRect(arenaRRect, groundPaint);

    // Subtle arena concentric dust rings
    final dustPaint = Paint()
      ..color = const Color(0xFFE4D5BC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(scoringZoneCenter, scoringZoneRadius * 1.8, dustPaint);

    // 2. Draw Central Target Scoring Zone
    final zoneFill = Paint()..color = AppColors.yellow.withAlpha(50);
    final zoneOutline = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(scoringZoneCenter, scoringZoneRadius, zoneFill);
    canvas.drawCircle(scoringZoneCenter, scoringZoneRadius, zoneOutline);

    // Inner bullseye ring
    canvas.drawCircle(
      scoringZoneCenter,
      scoringZoneRadius * 0.45,
      Paint()
        ..color = AppColors.coral.withAlpha(70)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      scoringZoneCenter,
      scoringZoneRadius * 0.45,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3. Draw Shooter Baseline
    final baseLinePaint = Paint()
      ..color = AppColors.primaryNavy.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(arenaBounds.left + 20, arenaBounds.bottom - 45),
      Offset(arenaBounds.right - 20, arenaBounds.bottom - 45),
      baseLinePaint,
    );

    // 4. Draw Arena Borders
    final wallOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(arenaRRect, wallOutline);

    // 5. Draw Marbles (Drop shadows first, then bodies)
    for (final m in marbles) {
      if (m.isScored) continue;
      // Shadow
      canvas.drawCircle(
        Offset(m.position.dx, m.position.dy + 3),
        m.radius * 0.95,
        Paint()..color = AppColors.primaryNavy.withAlpha(50),
      );
    }

    for (final m in marbles) {
      if (m.isScored) continue;
      _drawMarble(canvas, m);
    }

    // 6. Draw Aiming Slingshot & Trajectory Arrow
    if (isAiming && dragStart != null && dragCurrent != null) {
      _drawAimingGuide(canvas, dragStart!, dragCurrent!);
    }
  }

  void _drawMarble(Canvas canvas, Marble m) {
    final pos = m.position;
    final r = m.radius;

    // Body
    final fill = Paint()..color = m.color;
    final outline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(pos, r, fill);

    // Internal glass swirl
    final swirl = Path()
      ..moveTo(pos.dx - r * 0.5, pos.dy - r * 0.2)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + r * 0.45, pos.dy + r * 0.45);
    canvas.drawPath(
      swirl,
      Paint()
        ..color = m.swirlColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.32,
    );

    // Outline
    canvas.drawCircle(pos, r, outline);

    // Specular highlight
    final shine = Paint()..color = AppColors.white.withAlpha(220);
    canvas.drawCircle(Offset(pos.dx - r * 0.35, pos.dy - r * 0.35), r * 0.25, shine);

    // Shooter indicator ring
    if (m.isShooter) {
      canvas.drawCircle(
        pos,
        r + 4,
        Paint()
          ..color = AppColors.cyan.withAlpha(140)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawAimingGuide(Canvas canvas, Offset start, Offset current) {
    final dragVector = current - start;
    final dragDist = dragVector.distance;
    if (dragDist < 5.0) return;

    // Aim direction is opposite to drag
    final aimDir = -dragVector / dragDist;
    final power = dragDist.clamp(10.0, 120.0);
    final trajLength = power * 2.2;

    // Slingshot pull line
    final pullPaint = Paint()
      ..color = AppColors.coral
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, current, pullPaint);

    // Forward aim trajectory line (dotted)
    final aimPaint = Paint()
      ..color = AppColors.primaryNavy
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final endPoint = start + aimDir * trajLength;

    // Dotted segments
    const step = 14.0;
    final segments = (trajLength / step).toInt();
    for (int i = 0; i < segments; i += 2) {
      final p1 = start + aimDir * (i * step);
      final p2 = start + aimDir * (math.min((i + 1) * step, trajLength));
      canvas.drawLine(p1, p2, aimPaint);
    }

    // Arrowhead at trajectory end
    final arrowP1 = endPoint - aimDir * 14 + Offset(-aimDir.dy, aimDir.dx) * 8;
    final arrowP2 = endPoint - aimDir * 14 - Offset(-aimDir.dy, aimDir.dx) * 8;
    final arrowPath = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = AppColors.primaryNavy);
  }

  @override
  bool shouldRepaint(covariant GoliArenaPainter oldDelegate) {
    return true; // continuous simulation update
  }
}
