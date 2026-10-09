import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_mode.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/game_result_dialog.dart';
import '../../../core/widgets/kalikoot_header.dart';
import '../engine/goli_engine.dart';
import '../painter/goli_arena_painter.dart';

class GoliKaliScreen extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;

  const GoliKaliScreen({
    super.key,
    required this.mode,
    this.difficulty = Difficulty.medium,
  });

  @override
  State<GoliKaliScreen> createState() => _GoliKaliScreenState();
}

class _GoliKaliScreenState extends State<GoliKaliScreen> with SingleTickerProviderStateMixin {
  late final GoliEngine _engine;
  final StorageService _storage = StorageService();
  Ticker? _ticker;

  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isAiming = false;
  bool _isAITurnScheduled = false;
  Timer? _aiTimer;

  @override
  void initState() {
    super.initState();
    _engine = GoliEngine(
      mode: widget.mode,
      difficulty: widget.difficulty,
    );

    _ticker = createTicker((_) {
      if (_engine.isSimulating) {
        final finished = _engine.updateSimulation();
        setState(() {});

        if (finished) {
          FeedbackService().playRoundComplete();
          _checkMatchCompletion();
        }
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_engine.isSimulating || _engine.isMatchOver) return;
    if (widget.mode == GameMode.singlePlayer && _engine.currentTurn == 2) {
      return; // Computer's turn
    }

    final pos = details.localPosition;
    final shooter = _engine.shooterMarble;

    // Check if touch is near shooter marble
    final dist = (pos - shooter.position).distance;
    if (dist < shooter.radius + 30) {
      setState(() {
        _isAiming = true;
        _dragStart = shooter.position;
        _dragCurrent = pos;
      });
      FeedbackService().triggerHapticLight();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isAiming) return;
    setState(() {
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isAiming || _dragStart == null || _dragCurrent == null) {
      setState(() => _isAiming = false);
      return;
    }

    final dragVector = _dragCurrent! - _dragStart!;
    final dragDist = dragVector.distance;

    if (dragDist > 10.0) {
      // Impulse in opposite direction to drag
      final aimDir = -dragVector / dragDist;
      final power = (dragDist * 0.28).clamp(8.0, 32.0);
      final impulse = aimDir * power;

      _engine.shoot(impulse);
      FeedbackService().playMarble();
      FeedbackService().triggerHapticMedium();
    }

    setState(() {
      _isAiming = false;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  void _checkMatchCompletion() {
    if (_engine.isMatchOver) {
      _handleMatchOver();
    } else if (widget.mode == GameMode.singlePlayer && _engine.currentTurn == 2) {
      // Trigger AI turn after brief pause
      _scheduleAITurn();
    }
  }

  void _scheduleAITurn() {
    if (_isAITurnScheduled) return;
    _isAITurnScheduled = true;

    _aiTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _isAITurnScheduled = false;
      _engine.executeAIShot();
      FeedbackService().playMarble();
      setState(() {});
    });
  }

  void _handleMatchOver() async {
    _storage.incrementStat('matches_played');

    if (widget.mode == GameMode.singlePlayer) {
      final p1 = _engine.player1Score;
      final ai = _engine.player2Score;
      final isNewBest = await _storage.saveHighScoreIfBest('goli_kali', p1);

      final isWin = p1 > ai;
      final title = isWin ? 'VICTORY!' : (p1 == ai ? "IT'S A DRAW!" : 'AI WINS!');
      final sub = isWin
          ? 'You pocketed more marbles ($p1 pts) than the AI ($ai pts)!'
          : 'AI scored $ai pts vs your $p1 pts.';

      if (!mounted) return;
      GameResultDialog.show(
        context,
        title: title,
        subtitle: sub,
        scoreText: 'YOUR SCORE: $p1 PTS',
        isWinner: isWin,
        isNewHighScore: isNewBest,
        onPlayAgain: () {
          setState(() => _engine.reset());
        },
        onHome: () => Navigator.of(context).pop(),
      );
    } else {
      final p1 = _engine.player1Score;
      final p2 = _engine.player2Score;
      final title = p1 > p2 ? 'PLAYER 1 WINS!' : (p2 > p1 ? 'PLAYER 2 WINS!' : "IT'S A DRAW!");

      GameResultDialog.show(
        context,
        title: title,
        subtitle: 'P1: $p1 pts  |  P2: $p2 pts',
        scoreText: 'FINAL SCORE',
        isWinner: p1 != p2,
        onPlayAgain: () {
          setState(() => _engine.reset());
        },
        onHome: () => Navigator.of(context).pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            KaliKootHeader(
              title: 'GOLI KALI',
              showBack: true,
            ),

            // Top HUD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildHUD(),
            ),

            // Arena Area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final arenaRect = Rect.fromLTWH(
                    12,
                    12,
                    constraints.maxWidth - 24,
                    constraints.maxHeight - 24,
                  );

                  if (_engine.arenaBounds == Rect.zero) {
                    _engine.initializeArena(arenaRect);
                  }

                  return GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: GoliArenaPainter(
                            marbles: _engine.marbles,
                            arenaBounds: arenaRect,
                            scoringZoneCenter: _engine.scoringZoneCenter,
                            scoringZoneRadius: _engine.scoringZoneRadius,
                            dragStart: _dragStart,
                            dragCurrent: _dragCurrent,
                            isAiming: _isAiming,
                          ),
                        ),

                        // Turn prompt banner
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _buildTurnBanner(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    final isAI = widget.mode == GameMode.singlePlayer;
    final opponentLabel = isAI ? 'AI OPPONENT' : 'PLAYER 2';

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
          // P1 Score
          _buildScoreItem('PLAYER 1', _engine.player1Score, AppColors.coral, _engine.currentTurn == 1),

          // Shots Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'SHOT ${math.min(_engine.player1Shots + 1, _engine.maxShotsPerPlayer)} / ${_engine.maxShotsPerPlayer}',
              style: const TextStyle(
                fontFamily: AppTypography.fontTitle,
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),

          // P2 / AI Score
          _buildScoreItem(opponentLabel, _engine.player2Score, AppColors.cyan, _engine.currentTurn == 2),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color, bool isTurn) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTurn ? AppColors.white : Colors.white60,
            fontSize: 11,
            fontWeight: isTurn ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        Text(
          '$score pts',
          style: AppTypography.scoreNumber.copyWith(
            fontSize: 20,
            color: isTurn ? color : Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnBanner() {
    final isAITurn = widget.mode == GameMode.singlePlayer && _engine.currentTurn == 2;
    String text;
    Color bg;

    if (_engine.isSimulating) {
      text = 'MARBLES IN MOTION...';
      bg = AppColors.yellow;
    } else if (isAITurn) {
      text = 'AI IS AIMING...';
      bg = AppColors.cyan;
    } else {
      text = _engine.currentTurn == 1 ? 'P1: DRAG & RELEASE TO SHOOT' : 'P2: DRAG & RELEASE TO SHOOT';
      bg = _engine.currentTurn == 1 ? AppColors.coral : AppColors.cyan;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryNavy, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTypography.fontTitle,
          color: AppColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
