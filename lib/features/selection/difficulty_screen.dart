import 'package:flutter/material.dart';
import '../../core/models/difficulty.dart';
import '../../core/models/game_info.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/difficulty_slider.dart';
import '../../core/widgets/kalikoot_header.dart';

class DifficultyScreen extends StatefulWidget {
  final GameInfo game;
  final GameMode mode;

  const DifficultyScreen({
    super.key,
    required this.game,
    required this.mode,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  Difficulty _difficulty = Difficulty.medium;

  void _onPlay() {
    FeedbackService().playTap();
    switch (widget.game.id) {
      case GameId.uriyadi:
        Navigator.of(context).pushNamed(
          '/game/uriyadi',
          arguments: {'mode': widget.mode, 'difficulty': _difficulty},
        );
        break;
      case GameId.goliKali:
        Navigator.of(context).pushNamed(
          '/game/goli-kali',
          arguments: {'mode': widget.mode, 'difficulty': _difficulty},
        );
        break;
      case GameId.kalariClash:
        Navigator.of(context).pushNamed(
          '/game/kalari-clash',
          arguments: {'mode': widget.mode, 'difficulty': _difficulty},
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header matching reference
            KaliKootHeader(
              title: widget.game.title,
              showBack: true,
            ),

            // Instruction prompt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                widget.game.shortDescription,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // White rounded card containing face avatar, slider, description and play button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.primaryNavy, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryNavy,
                        offset: Offset(0, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Difficulty Slider with Expressive Face Avatar
                      DifficultySlider(
                        initialDifficulty: _difficulty,
                        onChanged: (newDiff) {
                          setState(() => _difficulty = newDiff);
                        },
                      ),

                      // Description of selected difficulty
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryNavy, width: 2),
                        ),
                        child: Text(
                          _difficulty.description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Bottom Play Button & Help Row
                      Row(
                        children: [
                          Expanded(
                            child: ChunkyButton(
                              label: 'PLAY',
                              backgroundColor: AppColors.yellow,
                              icon: Icons.play_arrow_rounded,
                              height: 60,
                              onPressed: _onPlay,
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () {
                              FeedbackService().playTap();
                              _showHelpDialog(context);
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardOutline, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.cardOutline,
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.question_mark_rounded,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primaryNavy, width: 3),
        ),
        title: Text(widget.game.title, style: AppTypography.titleLarge),
        content: Text(
          widget.game.fullDescription,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ChunkyButton(
            label: 'UNDERSTOOD',
            backgroundColor: AppColors.cyan,
            height: 48,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
