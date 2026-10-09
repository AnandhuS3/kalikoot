import 'package:flutter/material.dart';
import '../models/game_info.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chunky_button.dart';

class ComingSoonSheet extends StatelessWidget {
  final GameInfo game;
  final Widget illustration;

  const ComingSoonSheet({
    super.key,
    required this.game,
    required this.illustration,
  });

  static void show(BuildContext context, GameInfo game, Widget illustration) {
    FeedbackService().playTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ComingSoonSheet(game: game, illustration: illustration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.primaryNavy, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryNavy,
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.trackInactive,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),

            // Illustrated Preview
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryNavy, width: 3),
              ),
              child: Center(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: illustration,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryNavy, width: 2),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(
                  fontFamily: AppTypography.fontTitle,
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Game Title
            Text(
              game.title,
              style: AppTypography.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              game.fullDescription,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                label: 'GOT IT!',
                backgroundColor: AppColors.cyan,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
