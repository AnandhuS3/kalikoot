import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../engine/uriyadi_state.dart';

class UriyadiPainter extends CustomPainter {
  final double angle; // Pendulum angle in radians
  final double stickProgress; // 0.0 to 1.0 swing animation
  final HitQuality? hitQuality;
  final double hitEffectProgress; // 0.0 to 1.0 impact explosion animation

  UriyadiPainter({
    required this.angle,
    required this.stickProgress,
    this.hitQuality,
    required this.hitEffectProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pivotX = size.width / 2;
    final pivotY = 20.0;
    final ropeLength = size.height * 0.48;

    // Draw festive top hanging toran (mango leaves decoration)
    _drawFestiveToran(canvas, size);

    // Draw central target alignment guide
    _drawTargetGuide(canvas, size, pivotX, pivotY, ropeLength);

    // Calculate current pot position
    final potX = pivotX + ropeLength * math.sin(angle);
    final potY = pivotY + ropeLength * math.cos(angle);

    // Draw suspended ropes
    _drawRopes(canvas, pivotX, pivotY, potX, potY);

    // Draw Clay Pot (with shake offset if hit)
    double shakeX = 0;
    double shakeY = 0;
    if (hitEffectProgress > 0 && hitQuality != HitQuality.miss) {
      shakeX = 8 * math.sin(hitEffectProgress * math.pi * 10);
      shakeY = 4 * math.cos(hitEffectProgress * math.pi * 8);
    }

    _drawPot(canvas, potX + shakeX, potY + shakeY);

    // Draw splash / flower burst particles if hit
    if (hitEffectProgress > 0 && hitQuality != null && hitQuality != HitQuality.miss) {
      _drawHitBurst(canvas, potX, potY, hitEffectProgress, hitQuality!);
    }

    // Draw player's wooden hitting stick (Kambu)
    _drawHittingStick(canvas, size, pivotX, stickProgress);
  }

  void _drawFestiveToran(Canvas canvas, Size size) {
    final leafPaint = Paint()..color = AppColors.green;
    final leafOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const numLeaves = 12;
    final step = size.width / numLeaves;
    for (int i = 0; i <= numLeaves; i++) {
      final x = i * step;
      final leaf = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 8, 14, x, 22)
        ..quadraticBezierTo(x - 8, 14, x, 0)
        ..close();
      canvas.drawPath(leaf, leafPaint);
      canvas.drawPath(leaf, leafOutline);
    }
  }

  void _drawTargetGuide(Canvas canvas, Size size, double pivotX, double pivotY, double ropeLen) {
    final guidePaint = Paint()
      ..color = AppColors.primaryNavy.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Center vertical strike alignment line
    canvas.drawLine(
      Offset(pivotX, pivotY + ropeLen - 30),
      Offset(pivotX, pivotY + ropeLen + 50),
      guidePaint,
    );

    // Center target ring at apex
    final targetCenter = Offset(pivotX, pivotY + ropeLen);
    canvas.drawCircle(
      targetCenter,
      24,
      Paint()
        ..color = AppColors.yellow.withAlpha(70)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      targetCenter,
      24,
      Paint()
        ..color = AppColors.primaryNavy.withAlpha(90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawRopes(Canvas canvas, double px, double py, double potX, double potY) {
    final ropeOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final ropeFill = Paint()
      ..color = const Color(0xFFC8924A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Suspension pivot hook
    canvas.drawCircle(Offset(px, py), 6, Paint()..color = AppColors.primaryNavy);

    // Triple hanging braided ropes
    final path1 = Path()..moveTo(px, py)..lineTo(potX - 16, potY - 14);
    final path2 = Path()..moveTo(px, py)..lineTo(potX + 16, potY - 14);
    final path3 = Path()..moveTo(px, py)..lineTo(potX, potY - 18);

    for (final p in [path1, path2, path3]) {
      canvas.drawPath(p, ropeOutline);
      canvas.drawPath(p, ropeFill);
    }
  }

  void _drawPot(Canvas canvas, double cx, double cy) {
    final potFill = Paint()..color = const Color(0xFFE26A2C);
    final potOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Round belly clay pot
    final potPath = Path()
      ..moveTo(cx - 20, cy - 16)
      ..lineTo(cx + 20, cy - 16)
      ..quadraticBezierTo(cx + 36, cy + 4, cx + 24, cy + 30)
      ..quadraticBezierTo(cx, cy + 38, cx - 24, cy + 30)
      ..quadraticBezierTo(cx - 36, cy + 4, cx - 20, cy - 16)
      ..close();

    canvas.drawPath(potPath, potFill);
    canvas.drawPath(potPath, potOutline);

    // Decorative Yellow Festival Strip
    final bandPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawLine(Offset(cx - 26, cy + 8), Offset(cx + 26, cy + 8), bandPaint);

    // Hanging garland flowers around rim
    final flowerPaint = Paint()..color = AppColors.green;
    for (int i = -2; i <= 2; i++) {
      final fx = cx + (i * 9);
      final fy = cy - 14;
      canvas.drawCircle(Offset(fx, fy), 4, flowerPaint);
      canvas.drawCircle(
        Offset(fx, fy),
        4,
        Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawHitBurst(
    Canvas canvas,
    double cx,
    double cy,
    double progress,
    HitQuality quality,
  ) {
    final count = quality == HitQuality.perfect ? 16 : 8;
    final maxDist = quality == HitQuality.perfect ? 70.0 : 45.0;
    final currentDist = maxDist * progress;

    final particleColors = [
      AppColors.yellow,
      AppColors.white,
      AppColors.coral,
      const Color(0xFFE26A2C),
    ];

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count);
      final px = cx + currentDist * math.cos(angle);
      final py = cy + currentDist * math.sin(angle);
      final radius = (6.0 * (1.0 - progress * 0.6)).clamp(2.0, 6.0);

      final color = particleColors[i % particleColors.length];
      canvas.drawCircle(Offset(px, py), radius, Paint()..color = color);
      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawHittingStick(Canvas canvas, Size size, double pivotX, double progress) {
    if (progress <= 0) return;

    // Stick swings upward from bottom right towards pot center
    final angle = math.pi * 0.25 - (progress * math.pi * 0.45);
    final stickLen = 140.0;
    final startX = pivotX + 60 - (progress * 70);
    final startY = size.height * 0.85 - (progress * 80);

    final endX = startX + stickLen * math.cos(angle);
    final endY = startY - stickLen * math.sin(angle);

    final stickOutline = Paint()
      ..color = AppColors.primaryNavy
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final stickFill = Paint()
      ..color = const Color(0xFF8D5524)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), stickOutline);
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), stickFill);

    // Swing trail blur
    if (progress > 0.1 && progress < 0.9) {
      final trailPaint = Paint()
        ..color = AppColors.white.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(startX + 10, startY + 10),
        Offset(endX - 10, endY + 10),
        trailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant UriyadiPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.stickProgress != stickProgress ||
        oldDelegate.hitEffectProgress != hitEffectProgress;
  }
}
