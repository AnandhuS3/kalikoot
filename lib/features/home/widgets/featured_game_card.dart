import 'package:flutter/material.dart';
import '../../../core/models/game_info.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chunky_button.dart';
import 'game_illustrations.dart';

class FeaturedGameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onPlay;

  const FeaturedGameCard({
    super.key,
    required this.game,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FeedbackService().playTap();
        onPlay();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryNavy, width: 3.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryNavy,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryNavy, width: 2),
                  ),
                  child: const Text(
                    '★ FEATURED GAME',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryNavy, width: 2),
                  ),
                  child: const Text(
                    '1P & 2P',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle section: Illustration and details
            Row(
              children: [
                // Game Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryNavy, width: 2.5),
                  ),
                  child: Center(
                    child: GameIllustration(gameId: game.id, size: 85),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.shortDescription,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Play Button
            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                label: 'PLAY NOW',
                backgroundColor: AppColors.yellow,
                icon: Icons.play_arrow_rounded,
                onPressed: onPlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
