import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Interactive difficulty selector matching the visual reference:
/// Features an animated expressive character face avatar, bold difficulty label,
/// and a chunky 3-stop rounded slider.
class DifficultySlider extends StatefulWidget {
  final Difficulty initialDifficulty;
  final ValueChanged<Difficulty> onChanged;

  const DifficultySlider({
    super.key,
    this.initialDifficulty = Difficulty.medium,
    required this.onChanged,
  });

  @override
  State<DifficultySlider> createState() => _DifficultySliderState();
}

class _DifficultySliderState extends State<DifficultySlider> {
  late Difficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  void _updateDifficulty(Difficulty diff) {
    if (_selectedDifficulty != diff) {
      setState(() => _selectedDifficulty = diff);
      FeedbackService().playTap();
      FeedbackService().triggerHapticMedium();
      widget.onChanged(diff);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expressive Face Avatar in circular frame
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryNavy, width: 4),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryNavy,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(80, 80),
              painter: _DifficultyFacePainter(difficulty: _selectedDifficulty),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Difficulty Title
        Text(
          _selectedDifficulty.label,
          style: AppTypography.displayLarge.copyWith(
            color: _selectedDifficulty.color,
            fontSize: 32,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),

        // 3-Stop Chunky Rounded Slider Track
        Container(
          width: 220,
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.trackInactive,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryNavy, width: 3),
          ),
          child: Row(
            children: [
              _buildSegment(Difficulty.easy, 'EASY'),
              _buildSegment(Difficulty.medium, 'MED'),
              _buildSegment(Difficulty.hard, 'HARD'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          'Tap or drag to adjust difficulty',
          style: TextStyle(
            color: AppColors.mutedText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSegment(Difficulty difficulty, String label) {
    final isSelected = _selectedDifficulty == difficulty;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateDifficulty(difficulty),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? difficulty.color : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: AppColors.primaryNavy, width: 2)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.primaryNavy,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontTitle,
              color: isSelected ? AppColors.white : AppColors.primaryNavy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that renders expressive illustrated cartoon faces
/// matching the casual mobile game aesthetic.
class _DifficultyFacePainter extends CustomPainter {
  final Difficulty difficulty;

  _DifficultyFacePainter({required this.difficulty});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Face background fill
    final bgPaint = Paint()..color = difficulty.color;
    canvas.drawCircle(center, radius, bgPaint);

    // Thick black outline
    final outlinePaint = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, outlinePaint);

    final featurePaint = Paint()
      ..color = AppColors.primaryNavy
      ..style = PaintingStyle.fill;

    switch (difficulty) {
      case Difficulty.easy:
        // Happy, friendly eyes
        canvas.drawCircle(Offset(center.dx - 14, center.dy - 8), 6, featurePaint);
        canvas.drawCircle(Offset(center.dx + 14, center.dy - 8), 6, featurePaint);
        // Eye reflections
        final shine = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(center.dx - 12, center.dy - 10), 2.5, shine);
        canvas.drawCircle(Offset(center.dx + 16, center.dy - 10), 2.5, shine);
        // Wide smiling mouth
        final mouthPath = Path()
          ..moveTo(center.dx - 16, center.dy + 8)
          ..quadraticBezierTo(center.dx, center.dy + 24, center.dx + 16, center.dy + 8);
        final mouthStroke = Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4;
        canvas.drawPath(mouthPath, mouthStroke);
        break;

      case Difficulty.medium:
        // Smirking, cunning eyes (matching reference screenshot)
        // Left eye
        final leftEye = Path()
          ..moveTo(center.dx - 22, center.dy - 14)
          ..lineTo(center.dx - 8, center.dy - 6)
          ..quadraticBezierTo(center.dx - 15, center.dy + 2, center.dx - 22, center.dy - 14);
        canvas.drawPath(leftEye, featurePaint);
        // Right eye
        final rightEye = Path()
          ..moveTo(center.dx + 22, center.dy - 14)
          ..lineTo(center.dx + 8, center.dy - 6)
          ..quadraticBezierTo(center.dx + 15, center.dy + 2, center.dx + 22, center.dy - 14);
        canvas.drawPath(rightEye, featurePaint);
        // Sly smirk mouth
        final smirkPath = Path()
          ..moveTo(center.dx - 10, center.dy + 12)
          ..quadraticBezierTo(center.dx + 6, center.dy + 10, center.dx + 14, center.dy + 6);
        final smirkStroke = Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.5;
        canvas.drawPath(smirkPath, smirkStroke);
        break;

      case Difficulty.hard:
        // Fierce, determined angled brows & focused eyes
        final leftFierce = Path()
          ..moveTo(center.dx - 24, center.dy - 16)
          ..lineTo(center.dx - 6, center.dy - 8)
          ..lineTo(center.dx - 10, center.dy - 2)
          ..lineTo(center.dx - 22, center.dy - 6)
          ..close();
        canvas.drawPath(leftFierce, featurePaint);

        final rightFierce = Path()
          ..moveTo(center.dx + 24, center.dy - 16)
          ..lineTo(center.dx + 6, center.dy - 8)
          ..lineTo(center.dx + 10, center.dy - 2)
          ..lineTo(center.dx + 22, center.dy - 6)
          ..close();
        canvas.drawPath(rightFierce, featurePaint);

        // Determined toothy grin / grit mouth
        final gritRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx, center.dy + 12), width: 32, height: 12),
          const Radius.circular(6),
        );
        final gritFill = Paint()..color = AppColors.white;
        final gritOutline = Paint()
          ..color = AppColors.primaryNavy
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        canvas.drawRRect(gritRect, gritFill);
        canvas.drawRRect(gritRect, gritOutline);
        // Teeth marks
        canvas.drawLine(
          Offset(center.dx - 6, center.dy + 7),
          Offset(center.dx - 6, center.dy + 17),
          gritOutline,
        );
        canvas.drawLine(
          Offset(center.dx + 6, center.dy + 7),
          Offset(center.dx + 6, center.dy + 17),
          gritOutline,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DifficultyFacePainter oldDelegate) {
    return oldDelegate.difficulty != difficulty;
  }
}
