import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/game_info.dart';
import '../../../core/theme/app_colors.dart';

/// Renders custom vector-style illustrations using Flutter's CustomPainter.
/// Zero external raster images, fully scalable and offline.
class GameIllustration extends StatelessWidget {
  final GameId gameId;
  final double size;

  const GameIllustration({
    super.key,
    required this.gameId,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IllustrationPainter(gameId: gameId),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final GameId gameId;

  _IllustrationPainter({required this.gameId});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    switch (gameId) {
      case GameId.uriyadi:
        _paintUriyadi(canvas, size);
        break;
      case GameId.goliKali:
        _paintGoliKali(canvas, size);
        break;
      case GameId.kalariClash:
        _paintKalariClash(canvas, size);
        break;
      case GameId.vallamkali:
        _paintVallamkali(canvas, size);
        break;
      case GameId.pulikali:
        _paintPulikali(canvas, size);
        break;
      case GameId.yakshi:
        _paintYakshi(canvas, size);
        break;
      case GameId.nagapadam:
        _paintNagapadam(canvas, size);
        break;
      case GameId.monsoonMayhem:
        _paintMonsoonMayhem(canvas, size);
        break;
    }

    canvas.restore();
  }

  // 1. Uriyadi: Decorated clay pot suspended from a rope
  void _paintUriyadi(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final potY = size.height * 0.58;

    // Hanging ropes
    final ropePaint = Paint()
      ..color = const Color(0xFFC48842)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final ropeOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Three suspended ropes meeting at pot
    final ropePaths = [
      Path()..moveTo(cx, 0)..lineTo(cx - 24, potY - 14),
      Path()..moveTo(cx, 0)..lineTo(cx + 24, potY - 14),
      Path()..moveTo(cx, 0)..lineTo(cx, potY - 18),
    ];
    for (final p in ropePaths) {
      canvas.drawPath(p, ropeOutline);
      canvas.drawPath(p, ropePaint);
    }

    // Clay Pot Body
    final potPath = Path()
      ..moveTo(cx - 18, potY - 16)
      ..lineTo(cx + 18, potY - 16)
      ..quadraticBezierTo(cx + 34, potY + 4, cx + 22, potY + 28)
      ..quadraticBezierTo(cx, potY + 36, cx - 22, potY + 28)
      ..quadraticBezierTo(cx - 34, potY + 4, cx - 18, potY - 16)
      ..close();

    final potFill = Paint()..color = const Color(0xFFE26A2C);
    final potOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawPath(potPath, potFill);
    canvas.drawPath(potPath, potOutline);

    // Decorative Yellow/White Festival Band on Pot
    final bandPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawLine(Offset(cx - 24, potY + 8), Offset(cx + 24, potY + 8), bandPaint);

    // Decorative mango leaves / flowers hanging around neck
    final leafPaint = Paint()..color = AppColors.green;
    for (int i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(cx + (i * 10), potY - 14), 4.5, leafPaint);
      canvas.drawCircle(
        Offset(cx + (i * 10), potY - 14),
        4.5,
        Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Stick swing silhouette
    final stickPaint = Paint()
      ..color = const Color(0xFF935116)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx + 18, potY + 36),
      Offset(cx + 46, potY + 12),
      Paint()
        ..color = AppColors.primaryNavy
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(Offset(cx + 18, potY + 36), Offset(cx + 46, potY + 12), stickPaint);
  }

  // 2. Goli Kali: Colorful glass marbles with swirl cores
  void _paintGoliKali(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Arena dust circle
    final arenaPaint = Paint()..color = const Color(0xFFE6D7BD);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, arenaPaint);
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.42,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Marble 1: Large cyan shooter
    _paintMarble(canvas, Offset(cx - 16, cy + 12), 22, AppColors.cyan, AppColors.yellow);

    // Marble 2: Medium coral target
    _paintMarble(canvas, Offset(cx + 18, cy - 10), 17, AppColors.coral, AppColors.white);

    // Marble 3: Small green marble
    _paintMarble(canvas, Offset(cx - 8, cy - 24), 13, AppColors.green, AppColors.coral);

    // Marble 4: Small purple marble
    _paintMarble(canvas, Offset(cx + 26, cy + 22), 14, AppColors.purple, AppColors.cyan);
  }

  void _paintMarble(Canvas canvas, Offset pos, double r, Color mainColor, Color swirlColor) {
    // Marble body
    final fill = Paint()..color = mainColor;
    final outline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(pos, r, fill);

    // Swirl ribbon inside
    final swirl = Path()
      ..moveTo(pos.dx - r * 0.5, pos.dy - r * 0.2)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + r * 0.4, pos.dy + r * 0.4);
    final swirlPaint = Paint()
      ..color = swirlColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.28;
    canvas.drawPath(swirl, swirlPaint);

    // Outline
    canvas.drawCircle(pos, r, outline);

    // Highlight sheen
    final shine = Paint()..color = Colors.white.withAlpha(220);
    canvas.drawCircle(Offset(pos.dx - r * 0.35, pos.dy - r * 0.35), r * 0.22, shine);
  }

  // 3. Kalari Clash: Simplified martial-arts silhouettes clashing
  void _paintKalariClash(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Clash flash burst background
    final burstPaint = Paint()..color = AppColors.yellow;
    final burstPath = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final rOuter = size.width * 0.36;
      final rInner = size.width * 0.18;
      final ox = cx + rOuter * math.cos(angle);
      final oy = cy + rOuter * math.sin(angle);
      final ix = cx + rInner * math.cos(angle + math.pi / 8);
      final iy = cy + rInner * math.sin(angle + math.pi / 8);
      if (i == 0) {
        burstPath.moveTo(ox, oy);
      } else {
        burstPath.lineTo(ox, oy);
      }
      burstPath.lineTo(ix, iy);
    }
    burstPath.close();
    canvas.drawPath(burstPath, burstPaint);
    canvas.drawPath(
      burstPath,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Left Fighter (Coral sword strike)
    final fighterPaint = Paint()..color = AppColors.primaryNavy;
    // Head
    canvas.drawCircle(Offset(cx - 26, cy - 14), 7, fighterPaint);
    // Body / Stance
    final leftBody = Path()
      ..moveTo(cx - 26, cy - 8)
      ..lineTo(cx - 20, cy + 12)
      ..lineTo(cx - 34, cy + 28)
      ..moveTo(cx - 20, cy + 12)
      ..lineTo(cx - 10, cy + 28);
    canvas.drawPath(
      leftBody,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Curved Kerala Sword (Urumi / Vaal)
    final swordPath = Path()
      ..moveTo(cx - 18, cy)
      ..quadraticBezierTo(cx - 4, cy - 18, cx + 4, cy - 8);
    canvas.drawPath(
      swordPath,
      Paint()
        ..color = AppColors.coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );

    // Right Fighter (Cyan shield block)
    canvas.drawCircle(Offset(cx + 26, cy - 14), 7, fighterPaint);
    final rightBody = Path()
      ..moveTo(cx + 26, cy - 8)
      ..lineTo(cx + 20, cy + 12)
      ..lineTo(cx + 34, cy + 28)
      ..moveTo(cx + 20, cy + 12)
      ..lineTo(cx + 10, cy + 28);
    canvas.drawPath(
      rightBody,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Shield
    final shieldPaint = Paint()..color = AppColors.cyan;
    final shieldCenter = Offset(cx + 10, cy);
    canvas.drawCircle(shieldCenter, 11, shieldPaint);
    canvas.drawCircle(
      shieldCenter,
      11,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  // 4. Vallamkali: Stylised Kerala snake boat
  void _paintVallamkali(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // River waves
    final wavePaint = Paint()
      ..color = AppColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final wave1 = Path()
      ..moveTo(size.width * 0.1, cy + 22)
      ..quadraticBezierTo(cx, cy + 28, size.width * 0.9, cy + 22);
    canvas.drawPath(wave1, wavePaint);

    // Chundan Vallam hull (tall prow on left, long hull)
    final boatPath = Path()
      ..moveTo(size.width * 0.16, cy - 16)
      ..quadraticBezierTo(size.width * 0.18, cy + 14, size.width * 0.35, cy + 14)
      ..lineTo(size.width * 0.84, cy + 10)
      ..quadraticBezierTo(size.width * 0.92, cy + 4, size.width * 0.88, cy)
      ..lineTo(size.width * 0.32, cy + 4)
      ..quadraticBezierTo(size.width * 0.22, cy + 2, size.width * 0.16, cy - 16)
      ..close();

    final boatFill = Paint()..color = const Color(0xFF6B4423);
    final boatOutline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawPath(boatPath, boatFill);
    canvas.drawPath(boatPath, boatOutline);

    // Oarsmen dots
    final oarPaint = Paint()..color = AppColors.primaryNavy;
    for (int i = 0; i < 4; i++) {
      final ox = size.width * 0.38 + (i * 12);
      canvas.drawCircle(Offset(ox, cy - 2), 3.5, oarPaint);
      canvas.drawLine(
        Offset(ox, cy + 2),
        Offset(ox - 6, cy + 18),
        Paint()
          ..color = AppColors.yellow
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // 5. Pulikali: Playful tiger-face character
  void _paintPulikali(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Tiger round face
    final tigerFill = Paint()..color = AppColors.yellow;
    final outline = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Ears
    canvas.drawCircle(Offset(cx - 24, cy - 20), 10, Paint()..color = AppColors.coral);
    canvas.drawCircle(Offset(cx - 24, cy - 20), 10, outline);
    canvas.drawCircle(Offset(cx + 24, cy - 20), 10, Paint()..color = AppColors.coral);
    canvas.drawCircle(Offset(cx + 24, cy - 20), 10, outline);

    // Face
    canvas.drawCircle(Offset(cx, cy + 2), 28, tigerFill);
    canvas.drawCircle(Offset(cx, cy + 2), 28, outline);

    // Stripes
    final stripePaint = Paint()
      ..color = AppColors.primaryNavy
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 26, cy - 4), Offset(cx - 16, cy - 2), stripePaint);
    canvas.drawLine(Offset(cx + 26, cy - 4), Offset(cx + 16, cy - 2), stripePaint);
    canvas.drawLine(Offset(cx - 26, cy + 8), Offset(cx - 16, cy + 6), stripePaint);
    canvas.drawLine(Offset(cx + 26, cy + 8), Offset(cx + 16, cy + 6), stripePaint);

    // Eyes
    canvas.drawCircle(Offset(cx - 10, cy - 2), 4.5, Paint()..color = AppColors.primaryNavy);
    canvas.drawCircle(Offset(cx + 10, cy - 2), 4.5, Paint()..color = AppColors.primaryNavy);

    // Nose & Fangs
    canvas.drawCircle(Offset(cx, cy + 7), 4, Paint()..color = AppColors.coral);
    final tongue = Path()
      ..moveTo(cx - 6, cy + 16)
      ..quadraticBezierTo(cx, cy + 24, cx + 6, cy + 16)
      ..close();
    canvas.drawPath(tongue, Paint()..color = AppColors.coral);
    canvas.drawPath(tongue, outline);
  }

  // 6. Yakshi: Mysterious silhouette on a moonlit village path
  void _paintYakshi(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Full moon
    final moonPaint = Paint()..color = AppColors.yellow;
    canvas.drawCircle(Offset(cx + 14, cy - 14), 24, moonPaint);
    canvas.drawCircle(
      Offset(cx + 14, cy - 14),
      24,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Palm tree fronds
    final treePaint = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 30, cy + 28), Offset(cx - 24, cy - 18), treePaint);
    canvas.drawLine(Offset(cx - 24, cy - 18), Offset(cx - 40, cy - 26), treePaint);
    canvas.drawLine(Offset(cx - 24, cy - 18), Offset(cx - 10, cy - 28), treePaint);

    // Mysterious graceful white-clad silhouette
    final figurePath = Path()
      ..moveTo(cx + 4, cy + 4)
      ..lineTo(cx + 8, cy + 30)
      ..lineTo(cx - 6, cy + 30)
      ..close();
    canvas.drawPath(figurePath, Paint()..color = AppColors.white);
    canvas.drawPath(
      figurePath,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(cx + 2, cy - 2),
      5,
      Paint()..color = AppColors.primaryNavy,
    );
  }

  // 7. Nagapadam: Serpentine sacred knot
  void _paintNagapadam(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final knotPaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final outlinePaint = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(cx - 24, cy - 16)
      ..cubicTo(cx - 34, cy + 24, cx + 34, cy + 24, cx + 24, cy - 16)
      ..cubicTo(cx + 12, cy - 32, cx - 12, cy - 32, cx - 24, cy - 16)
      ..close();

    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, knotPaint);

    // Center jewel / bindu
    canvas.drawCircle(Offset(cx, cy), 7, Paint()..color = AppColors.yellow);
    canvas.drawCircle(
      Offset(cx, cy),
      7,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  // 8. Monsoon Mayhem: Traditional umbrella with rain
  void _paintMonsoonMayhem(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Raindrops
    final dropPaint = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 28, cy - 24), Offset(cx - 24, cy - 12), dropPaint);
    canvas.drawLine(Offset(cx + 16, cy - 30), Offset(cx + 20, cy - 18), dropPaint);
    canvas.drawLine(Offset(cx - 10, cy - 28), Offset(cx - 6, cy - 16), dropPaint);
    canvas.drawLine(Offset(cx + 30, cy - 12), Offset(cx + 34, cy), dropPaint);

    // Umbrella dome
    final dome = Path()
      ..moveTo(cx - 30, cy + 4)
      ..quadraticBezierTo(cx, cy - 32, cx + 30, cy + 4)
      ..quadraticBezierTo(cx + 20, cy + 2, cx + 10, cy + 4)
      ..quadraticBezierTo(cx, cy + 2, cx - 10, cy + 4)
      ..quadraticBezierTo(cx - 20, cy + 2, cx - 30, cy + 4)
      ..close();

    canvas.drawPath(dome, Paint()..color = AppColors.purple);
    canvas.drawPath(
      dome,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Handle
    final handle = Path()
      ..moveTo(cx, cy - 12)
      ..lineTo(cx, cy + 24)
      ..quadraticBezierTo(cx - 6, cy + 30, cx - 12, cy + 24);
    canvas.drawPath(
      handle,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) {
    return oldDelegate.gameId != gameId;
  }
}
