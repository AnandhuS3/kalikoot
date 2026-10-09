import 'package:flutter/material.dart';
import '../../../core/models/game_info.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'game_illustrations.dart';

class GameGridCard extends StatefulWidget {
  final GameInfo game;
  final VoidCallback onTap;

  const GameGridCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  State<GameGridCard> createState() => _GameGridCardState();
}

class _GameGridCardState extends State<GameGridCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final depth = _isPressed ? 0.0 : 4.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        FeedbackService().playTap();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: _isPressed ? depth : 0, bottom: _isPressed ? 0 : depth),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryNavy, width: 3.5),
          boxShadow: depth > 0
              ? const [
                  BoxShadow(
                    color: AppColors.primaryNavy,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration area with optional "Coming Soon" badge
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: AppColors.background.withAlpha(120),
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: GameIllustration(gameId: game.id, size: 85),
                      ),
                    ),
                    if (!game.isPlayable)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryNavy, width: 1.5),
                          ),
                          child: const Text(
                            'SOON',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Accent Color Title Pill (matching visual reference)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: game.accentColor,
                  border: const Border(
                    top: BorderSide(color: AppColors.primaryNavy, width: 2.5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  game.title.toUpperCase(),
                  style: AppTypography.pillLabel.copyWith(
                    color: game.accentColor == AppColors.yellow
                        ? AppColors.primaryNavy
                        : AppColors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
