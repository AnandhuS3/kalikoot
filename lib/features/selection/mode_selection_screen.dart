import 'package:flutter/material.dart';
import '../../core/models/game_info.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/kalikoot_header.dart';

class ModeSelectionScreen extends StatelessWidget {
  final GameInfo game;

  const ModeSelectionScreen({
    super.key,
    required this.game,
  });

  void _onSelectMode(BuildContext context, GameMode mode) {
    FeedbackService().playTap();
    if (mode == GameMode.singlePlayer) {
      Navigator.of(context).pushNamed(
        '/difficulty-select',
        arguments: {'game': game, 'mode': mode},
      );
    } else {
      // 2-Player mode goes directly to game screen
      _navigateToGame(context, mode);
    }
  }

  void _navigateToGame(BuildContext context, GameMode mode) {
    switch (game.id) {
      case GameId.uriyadi:
        Navigator.of(context).pushNamed(
          '/game/uriyadi',
          arguments: {'mode': mode},
        );
        break;
      case GameId.goliKali:
        Navigator.of(context).pushNamed(
          '/game/goli-kali',
          arguments: {'mode': mode},
        );
        break;
      case GameId.kalariClash:
        Navigator.of(context).pushNamed(
          '/game/kalari-clash',
          arguments: {'mode': mode},
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
            KaliKootHeader(
              title: game.title,
              showBack: true,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'CHOOSE MODE',
                    style: AppTypography.displayMedium.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select how you want to play ${game.title}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1 PLAYER CARD (Matching visual reference style)
                    _ModeCard(
                      numberText: '1',
                      badgeLabel: '1 PLAYER',
                      badgeColor: AppColors.coral,
                      description: 'Play against intelligent computer opponent with 3 difficulty levels.',
                      icon: Icons.person_rounded,
                      onTap: () => _onSelectMode(context, GameMode.singlePlayer),
                    ),
                    const SizedBox(height: 20),

                    // 2 PLAYERS CARD
                    _ModeCard(
                      numberText: '2',
                      badgeLabel: '2 PLAYERS',
                      badgeColor: AppColors.cyan,
                      description: 'Play head-to-head on the same phone. Alternating turns and instant rematches!',
                      icon: Icons.people_alt_rounded,
                      onTap: () => _onSelectMode(context, GameMode.twoPlayer),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final String numberText;
  final String badgeLabel;
  final Color badgeColor;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.numberText,
    required this.badgeLabel,
    required this.badgeColor,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final depth = _isPressed ? 0.0 : 5.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: _isPressed ? depth : 0, bottom: _isPressed ? 0 : depth),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.cardOutline, width: 3.5),
          boxShadow: depth > 0
              ? const [
                  BoxShadow(
                    color: AppColors.cardOutline,
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Giant chunky numeral
                    Text(
                      widget.numberText,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: widget.badgeColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Description
                    Expanded(
                      child: Text(
                        widget.description,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: Colors.white70, size: 32),
                  ],
                ),
              ),

              // Bottom Bright Action Pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: widget.badgeColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.badgeLabel,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
