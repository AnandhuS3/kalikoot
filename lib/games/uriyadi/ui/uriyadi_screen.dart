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
import '../engine/uriyadi_engine.dart';
import '../engine/uriyadi_state.dart';
import '../painter/uriyadi_painter.dart';

class UriyadiScreen extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;

  const UriyadiScreen({
    super.key,
    required this.mode,
    this.difficulty = Difficulty.medium,
  });

  @override
  State<UriyadiScreen> createState() => _UriyadiScreenState();
}

class _UriyadiScreenState extends State<UriyadiScreen> with TickerProviderStateMixin {
  late final UriyadiEngine _engine;
  final StorageService _storage = StorageService();

  late final AnimationController _swingController;
  late final AnimationController _stickController;
  late final AnimationController _hitEffectController;

  double _elapsedTime = 0.0;
  Timer? _cooldownTimer;
  HitQuality? _displayQuality;

  @override
  void initState() {
    super.initState();
    _engine = UriyadiEngine(
      mode: widget.mode,
      difficulty: widget.difficulty,
    );

    // Continuous swinging animation ticker
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        if (_engine.state == UriyadiState.swinging) {
          setState(() {
            _elapsedTime += 0.016; // ~60fps step
          });
        }
      });
    _swingController.repeat();

    // Hitting stick swing animation
    _stickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Hit impact & particle burst animation
    _hitEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _engine.startRound();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _swingController.dispose();
    _stickController.dispose();
    _hitEffectController.dispose();
    super.dispose();
  }

  void _onHitPressed() {
    if (_engine.state != UriyadiState.swinging) return;

    // Trigger stick swing animation
    _stickController.forward(from: 0.0);

    // Register hit with current time
    final quality = _engine.registerHit(_elapsedTime);
    if (quality != null) {
      setState(() {
        _displayQuality = quality;
      });

      if (quality == HitQuality.miss) {
        FeedbackService().playMiss();
      } else {
        FeedbackService().playHit();
        if (quality == HitQuality.perfect) {
          FeedbackService().triggerHapticHeavy();
        }
        _hitEffectController.forward(from: 0.0);
      }

      // Brief cooldown before next turn or round completion
      _cooldownTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _displayQuality = null;

        if (_engine.isMatchOver) {
          _handleMatchCompletion();
        } else {
          setState(() {
            _engine.advanceTurn();
            _engine.startRound();
          });
        }
      });
    }
  }

  void _handleMatchCompletion() async {
    _storage.incrementStat('matches_played');

    if (widget.mode == GameMode.singlePlayer) {
      final score = _engine.player1Score;
      final isNewBest = await _storage.saveHighScoreIfBest('uriyadi', score);

      if (!mounted) return;
      GameResultDialog.show(
        context,
        title: 'MATCH COMPLETE!',
        subtitle: 'You shattered the festival pots!',
        scoreText: '$score POINTS',
        isWinner: true,
        isNewHighScore: isNewBest,
        onPlayAgain: () {
          setState(() {
            _engine.reset();
            _engine.startRound();
          });
        },
        onHome: () => Navigator.of(context).pop(),
      );
    } else {
      final p1 = _engine.player1Score;
      final p2 = _engine.player2Score;
      String resultTitle;
      String resultSubtitle;

      if (p1 > p2) {
        resultTitle = 'PLAYER 1 WINS!';
        resultSubtitle = 'P1 ($p1 pts) defeated P2 ($p2 pts)';
      } else if (p2 > p1) {
        resultTitle = 'PLAYER 2 WINS!';
        resultSubtitle = 'P2 ($p2 pts) defeated P1 ($p1 pts)';
      } else {
        resultTitle = "IT'S A DRAW!";
        resultSubtitle = 'Both players scored $p1 pts!';
      }

      GameResultDialog.show(
        context,
        title: resultTitle,
        subtitle: resultSubtitle,
        scoreText: 'P1: $p1  |  P2: $p2',
        isWinner: p1 != p2,
        onPlayAgain: () {
          setState(() {
            _engine.reset();
            _engine.startRound();
          });
        },
        onHome: () => Navigator.of(context).pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAngle = _engine.calculateAngle(_elapsedTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            KaliKootHeader(
              title: 'URIYADI CHALLENGE',
              showBack: true,
            ),

            // Top HUD Scoreboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildHUD(),
            ),

            // Active Game Surface
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onHitPressed,
                child: Container(
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
                        // Custom Painter
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _stickController,
                            _hitEffectController,
                          ]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: UriyadiPainter(
                                angle: currentAngle,
                                stickProgress: _stickController.value,
                                hitQuality: _displayQuality,
                                hitEffectProgress: _hitEffectController.value,
                              ),
                            );
                          },
                        ),

                        // Hit Quality Outcome Overlay Banner
                        if (_displayQuality != null)
                          Center(
                            child: _buildHitBanner(_displayQuality!),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Hit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ChunkyButton(
                  label: _engine.state == UriyadiState.swinging ? 'STRIKE POT!' : 'WAIT...',
                  backgroundColor: _engine.state == UriyadiState.swinging
                      ? AppColors.yellow
                      : AppColors.trackInactive,
                  height: 64,
                  icon: Icons.sports_kabaddi_rounded,
                  onPressed: _engine.state == UriyadiState.swinging ? _onHitPressed : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    if (widget.mode == GameMode.singlePlayer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardOutline, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCORE',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${_engine.player1Score} pts',
                  style: AppTypography.scoreNumber.copyWith(fontSize: 22),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.difficulty.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: Text(
                'ATTEMPT ${_engine.currentAttemptNumber} / ${_engine.maxAttemptsPerPlayer}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'DIFFICULTY',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.difficulty.label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 2-Player HUD
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardOutline, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlayerScore(
              'PLAYER 1',
              _engine.player1Score,
              AppColors.coral,
              _engine.currentTurn == 1,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'P${_engine.currentTurn}\'s TURN',
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            _buildPlayerScore(
              'PLAYER 2',
              _engine.player2Score,
              AppColors.cyan,
              _engine.currentTurn == 2,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPlayerScore(String label, int score, Color color, bool isTurn) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isTurn ? AppColors.white : Colors.white60,
                fontWeight: isTurn ? FontWeight.w900 : FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          '$score',
          style: AppTypography.scoreNumber.copyWith(
            fontSize: 22,
            color: isTurn ? color : Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildHitBanner(HitQuality quality) {
    Color bg;
    switch (quality) {
      case HitQuality.perfect:
        bg = AppColors.yellow;
        break;
      case HitQuality.great:
        bg = AppColors.green;
        break;
      case HitQuality.good:
        bg = AppColors.cyan;
        break;
      case HitQuality.miss:
        bg = AppColors.coral;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryNavy, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryNavy,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quality.label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            '+${quality.points} PTS',
            style: const TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
