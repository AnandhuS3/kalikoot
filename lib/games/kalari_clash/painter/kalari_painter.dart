import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/kalari_action.dart';

class KalariPainter extends CustomPainter {
  final KalariAction? p1Action;
  final KalariAction? p2Action;
  final bool isRevealed;
  final double animationProgress; // 0.0 to 1.0 for strike/impact
  final int? p1Damage;
  final int? p2Damage;

  KalariPainter({
    this.p1Action,
    this.p2Action,
    required this.isRevealed,
    required this.animationProgress,
    this.p1Damage,
    this.p2Damage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // 1. Draw Kalari Arena Floor (warm Kerala red earth circle)
    final floorPaint = Paint()..color = const Color(0xFFEBD8BE);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 30), width: size.width * 0.85, height: 90),
      floorPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 30), width: size.width * 0.85, height: 90),
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Center arena demarcation line
    canvas.drawLine(
      Offset(cx, cy - 10),
      Offset(cx, cy + 70),
      Paint()
        ..color = AppColors.primaryNavy.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Compute fighter offsets based on action and animation progress
    double p1OffsetX = 0;
    double p2OffsetX = 0;

    if (isRevealed) {
      if (p1Action == KalariAction.attack) {
        p1OffsetX = 35 * math.sin(animationProgress * math.pi);
      } else if (p1Action == KalariAction.dodge) {
        p1OffsetX = -25 * math.sin(animationProgress * math.pi);
      }

      if (p2Action == KalariAction.attack) {
        p2OffsetX = -35 * math.sin(animationProgress * math.pi);
      } else if (p2Action == KalariAction.dodge) {
        p2OffsetX = 25 * math.sin(animationProgress * math.pi);
      }
    }

    final p1Pos = Offset(cx - 75 + p1OffsetX, cy);
    final p2Pos = Offset(cx + 75 + p2OffsetX, cy);

    // 2. Draw Left Fighter (Player 1)
    _drawFighter(
      canvas,
      p1Pos,
      isFacingRight: true,
      accentColor: AppColors.coral,
      action: isRevealed ? p1Action : null,
      animProgress: animationProgress,
    );

    // 3. Draw Right Fighter (Player 2 / AI)
    _drawFighter(
      canvas,
      p2Pos,
      isFacingRight: false,
      accentColor: AppColors.cyan,
      action: isRevealed ? p2Action : null,
      animProgress: animationProgress,
    );

    // 4. Draw Center Clash Sparks if both struck or blocked
    if (isRevealed && animationProgress > 0.1 && animationProgress < 0.9) {
      _drawClashSparks(canvas, Offset(cx, cy - 10), animationProgress);
    }

    // 5. Floating Damage indicators
    if (isRevealed && animationProgress > 0.2) {
      if (p1Damage != null && p1Damage! > 0) {
        _drawDamageText(canvas, Offset(p1Pos.dx, p1Pos.dy - 65), '-$p1Damage', AppColors.coral);
      }
      if (p2Damage != null && p2Damage! > 0) {
        _drawDamageText(canvas, Offset(p2Pos.dx, p2Pos.dy - 65), '-$p2Damage', AppColors.cyan);
      }
    }
  }

  void _drawFighter(
    Canvas canvas,
    Offset pos, {
    required bool isFacingRight,
    required Color accentColor,
    required KalariAction? action,
    required double animProgress,
  }) {
    final dir = isFacingRight ? 1.0 : -1.0;
    final bodyPaint = Paint()..color = AppColors.primaryNavy;

    // Head
    canvas.drawCircle(Offset(pos.dx, pos.dy - 35), 11, bodyPaint);
    // Forehead band
    canvas.drawLine(
      Offset(pos.dx - 8, pos.dy - 38),
      Offset(pos.dx + 8, pos.dy - 38),
      Paint()
        ..color = accentColor
        ..strokeWidth = 3,
    );

    // Torso
    final torso = Path()
      ..moveTo(pos.dx, pos.dy - 24)
      ..lineTo(pos.dx + dir * 6, pos.dy + 8);
    canvas.drawPath(
      torso,
      Paint()
        ..color = AppColors.primaryNavy
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Legs (Martial Arts Stance)
    final leftLeg = Path()
      ..moveTo(pos.dx + dir * 6, pos.dy + 8)
      ..lineTo(pos.dx - dir * 18, pos.dy + 34);
    final rightLeg = Path()
      ..moveTo(pos.dx + dir * 6, pos.dy + 8)
      ..lineTo(pos.dx + dir * 20, pos.dy + 34);

    for (final leg in [leftLeg, rightLeg]) {
      canvas.drawPath(
        leg,
        Paint()
          ..color = AppColors.primaryNavy
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Weapons / Defenses based on action
    if (action == KalariAction.attack) {
      // Curved Sword Slash
      final swordStart = Offset(pos.dx + dir * 10, pos.dy - 10);
      final swordEnd = Offset(pos.dx + dir * 45, pos.dy - 8);

      canvas.drawLine(
        swordStart,
        swordEnd,
        Paint()
          ..color = AppColors.primaryNavy
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        swordStart,
        swordEnd,
        Paint()
          ..color = accentColor
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    } else if (action == KalariAction.block) {
      // Round Shield
      final shieldCenter = Offset(pos.dx + dir * 20, pos.dy - 8);
      canvas.drawCircle(shieldCenter, 18, Paint()..color = AppColors.white);
      canvas.drawCircle(
        shieldCenter,
        18,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        shieldCenter,
        18,
        Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else if (action == KalariAction.dodge) {
      // Dodge wind trail
      final swirl = Path()
        ..moveTo(pos.dx - dir * 15, pos.dy)
        ..quadraticBezierTo(pos.dx - dir * 30, pos.dy - 20, pos.dx - dir * 10, pos.dy - 35);
      canvas.drawPath(
        swirl,
        Paint()
          ..color = AppColors.cyan.withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Default Ready Stance Guard
      canvas.drawLine(
        Offset(pos.dx, pos.dy - 12),
        Offset(pos.dx + dir * 18, pos.dy - 16),
        Paint()
          ..color = AppColors.primaryNavy
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawClashSparks(Canvas canvas, Offset center, double progress) {
    final count = 10;
    final dist = 35.0 * progress;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count);
      final p1 = Offset(center.dx + dist * math.cos(angle), center.dy + dist * math.sin(angle));
      final p2 = Offset(center.dx + (dist + 8) * math.cos(angle), center.dy + (dist + 8) * math.sin(angle));

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = i % 2 == 0 ? AppColors.yellow : AppColors.coral
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawDamageText(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: AppColors.primaryNavy, offset: Offset(1, 1), blurRadius: 0),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant KalariPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isRevealed != isRevealed ||
        oldDelegate.p1Action != p1Action ||
        oldDelegate.p2Action != p2Action;
  }
}
