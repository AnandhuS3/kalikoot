import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chunky_button.dart';

class GameResultDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? scoreText;
  final bool isWinner;
  final bool isNewHighScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameResultDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.scoreText,
    this.isWinner = true,
    this.isNewHighScore = false,
    required this.onPlayAgain,
    required this.onHome,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? scoreText,
    bool isWinner = true,
    bool isNewHighScore = false,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
  }) {
    if (isWinner) {
      FeedbackService().playVictory();
    } else {
      FeedbackService().playRoundComplete();
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameResultDialog(
        title: title,
        subtitle: subtitle,
        scoreText: scoreText,
        isWinner: isWinner,
        isNewHighScore: isNewHighScore,
        onPlayAgain: onPlayAgain,
        onHome: onHome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryNavy, width: 4),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryNavy,
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cheerful Trophy / Medal Badge
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isWinner ? AppColors.yellow : AppColors.cyan,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryNavy, width: 3.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryNavy,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                isWinner ? Icons.emoji_events_rounded : Icons.star_rounded,
                size: 52,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Main Title
            Text(
              title,
              style: AppTypography.displayMedium.copyWith(
                color: isWinner ? AppColors.coral : AppColors.primaryNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            if (scoreText != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryNavy, width: 2.5),
                ),
                child: Text(
                  scoreText!,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ],

            if (isNewHighScore) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryNavy, width: 2),
                ),
                child: const Text(
                  '★ NEW HIGH SCORE! ★',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                label: 'PLAY AGAIN',
                backgroundColor: AppColors.yellow,
                icon: Icons.replay_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  onPlayAgain();
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                label: 'RETURN TO GAMES',
                backgroundColor: AppColors.white,
                textColor: AppColors.primaryNavy,
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  onHome();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
