import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_mode.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/game_result_dialog.dart';
import '../../../core/widgets/kalikoot_header.dart';
import '../engine/kalari_action.dart';
import '../engine/kalari_engine.dart';
import '../painter/kalari_painter.dart';

class KalariClashScreen extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;

  const KalariClashScreen({
    super.key,
    required this.mode,
    this.difficulty = Difficulty.medium,
  });

  @override
  State<KalariClashScreen> createState() => _KalariClashScreenState();
}

class _KalariClashScreenState extends State<KalariClashScreen> with SingleTickerProviderStateMixin {
  late final KalariEngine _engine;
  final StorageService _storage = StorageService();

  late final AnimationController _clashAnimController;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _engine = KalariEngine(
      mode: widget.mode,
      difficulty: widget.difficulty,
    );

    _clashAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _clashAnimController.dispose();
    _revealTimer?.cancel();
    super.dispose();
  }

  void _onActionSelected(KalariAction action) {
    FeedbackService().playTap();

    if (_engine.phase == KalariPhase.p1Choosing) {
      setState(() {
        _engine.chooseP1Action(action);
      });

      if (widget.mode == GameMode.singlePlayer) {
        _startRevealAnimation();
      }
    } else if (_engine.phase == KalariPhase.p2Choosing) {
      setState(() {
        _engine.chooseP2Action(action);
      });
      _startRevealAnimation();
    }
  }

  void _startRevealAnimation() {
    FeedbackService().playClash();
    FeedbackService().triggerHapticHeavy();
    _clashAnimController.forward(from: 0.0);

    _revealTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      if (_engine.isMatchOver) {
        _handleMatchOver();
      } else {
        setState(() {
          _engine.advanceToNextRound();
        });
      }
    });
  }

  void _handleMatchOver() {
    _storage.incrementStat('matches_played');
    final isDraw = _engine.player1HP <= 0 && _engine.player2HP <= 0;
    final p1Wins = _engine.player2HP <= 0 && _engine.player1HP > 0;

    String title;
    String subtitle;

    if (widget.mode == GameMode.singlePlayer) {
      if (p1Wins) {
        title = 'VICTORY!';
        subtitle = 'You outmaneuvered the AI opponent!';
        _storage.incrementStat('kalari_1p_wins');
      } else if (isDraw) {
        title = "MUTUAL TIE!";
        subtitle = 'Both martial warriors fell together.';
      } else {
        title = 'DEFEAT!';
        subtitle = 'The AI anticipated your stances.';
      }
    } else {
      title = p1Wins ? 'PLAYER 1 WINS!' : (isDraw ? "MUTUAL DRAW!" : 'PLAYER 2 WINS!');
      subtitle = 'P1 HP: ${_engine.player1HP} | P2 HP: ${_engine.player2HP}';
    }

    GameResultDialog.show(
      context,
      title: title,
      subtitle: subtitle,
      scoreText: 'MATCH OVER',
      isWinner: p1Wins,
      onPlayAgain: () {
        setState(() => _engine.reset());
      },
      onHome: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            KaliKootHeader(
              title: 'KALARI CLASH',
              showBack: true,
            ),

            // HP and Stamina Status Bars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildHealthBar(),
            ),

            // Middle Combat Arena
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primaryNavy, width: 3.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryNavy,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _clashAnimController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size.infinite,
                                painter: KalariPainter(
                                  p1Action: _engine.lastResult?.p1Action,
                                  p2Action: _engine.lastResult?.p2Action,
                                  isRevealed: _engine.phase == KalariPhase.revealing,
                                  animationProgress: _clashAnimController.value,
                                  p1Damage: _engine.lastResult?.p1Damage,
                                  p2Damage: _engine.lastResult?.p2Damage,
                                ),
                              );
                            },
                          ),

                          // Round resolution description
                          if (_engine.phase == KalariPhase.revealing && _engine.lastResult != null)
                            Positioned(
                              top: 16,
                              left: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNavy,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.white, width: 2),
                                ),
                                child: Text(
                                  _engine.lastResult!.summary,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontTitle,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 2-Player Concealed Handoff Overlay
                  if (_engine.phase == KalariPhase.handoff)
                    _buildHandoffOverlay(),
                ],
              ),
            ),

            // Bottom Action Selection Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar() {
    final opponentName = widget.mode == GameMode.singlePlayer ? 'AI' : 'P2';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardOutline, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // P1 Status
              Expanded(
                child: _buildFighterStatus('PLAYER 1', _engine.player1HP, _engine.player1Stamina, AppColors.coral),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontFamily: AppTypography.fontTitle,
                    color: AppColors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // P2 / AI Status
              Expanded(
                child: _buildFighterStatus(opponentName, _engine.player2HP, _engine.player2Stamina, AppColors.cyan),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFighterStatus(String name, int hp, int stamina, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: AppTypography.fontTitle,
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '$hp HP',
              style: const TextStyle(
                fontFamily: AppTypography.fontTitle,
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // HP Bar
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.white, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (hp / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: hp > 30 ? color : AppColors.coral,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Stamina Bar
        Row(
          children: [
            const Text(
              'STM ',
              style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (stamina / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isResolving = _engine.phase == KalariPhase.revealing;
    final prompt = _engine.phase == KalariPhase.p2Choosing
        ? 'PLAYER 2: SELECT MOVE'
        : 'PLAYER 1: SELECT MOVE';

    return Column(
      children: [
        Text(
          isResolving ? 'CLASH IN PROGRESS...' : prompt,
          style: const TextStyle(
            fontFamily: AppTypography.fontTitle,
            color: AppColors.primaryNavy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: ChunkyButton(
                label: 'ATTACK',
                backgroundColor: AppColors.coral,
                icon: Icons.flash_on_rounded,
                height: 58,
                onPressed: isResolving ? null : () => _onActionSelected(KalariAction.attack),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChunkyButton(
                label: 'BLOCK',
                backgroundColor: AppColors.cyan,
                icon: Icons.shield_rounded,
                height: 58,
                onPressed: isResolving ? null : () => _onActionSelected(KalariAction.block),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChunkyButton(
                label: 'DODGE',
                backgroundColor: AppColors.green,
                icon: Icons.fast_forward_rounded,
                height: 58,
                onPressed: isResolving ? null : () => _onActionSelected(KalariAction.dodge),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHandoffOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardOutline, width: 4),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: const Icon(Icons.screen_rotation_rounded, size: 48, color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 20),
              const Text(
                'PASS PHONE TO PLAYER 2',
                style: TextStyle(
                  fontFamily: AppTypography.fontTitle,
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Player 1’s stance is locked and hidden.\nHand device to Player 2.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ChunkyButton(
                label: 'I\'M READY, PLAYER 2',
                backgroundColor: AppColors.green,
                height: 54,
                onPressed: () {
                  FeedbackService().playTap();
                  setState(() => _engine.confirmHandoff());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
