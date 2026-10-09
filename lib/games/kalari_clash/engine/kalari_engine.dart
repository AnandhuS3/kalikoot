import 'dart:math' as math;
import '../../../core/models/difficulty.dart';
import '../../../core/models/game_mode.dart';
import 'kalari_action.dart';
import 'kalari_ai.dart';

enum KalariPhase {
  p1Choosing,
  handoff,
  p2Choosing,
  revealing,
  roundComplete,
  matchComplete,
}

class KalariEngine {
  final Difficulty difficulty;
  final GameMode mode;

  int _player1HP = 100;
  int _player2HP = 100;
  int _player1Stamina = 100;
  int _player2Stamina = 100;

  KalariPhase _phase = KalariPhase.p1Choosing;
  KalariAction? _p1SecretAction;
  KalariAction? _p2SecretAction;
  KalariRoundResult? _lastResult;

  final List<KalariAction> _player1History = [];
  final List<KalariAction> _player2History = [];
  final KalariAI _ai = KalariAI();

  KalariEngine({
    this.difficulty = Difficulty.medium,
    this.mode = GameMode.singlePlayer,
  });

  // Getters
  int get player1HP => _player1HP;
  int get player2HP => _player2HP;
  int get player1Stamina => _player1Stamina;
  int get player2Stamina => _player2Stamina;
  KalariPhase get phase => _phase;
  KalariRoundResult? get lastResult => _lastResult;
  KalariAction? get p1SecretAction => _p1SecretAction;
  KalariAction? get p2SecretAction => _p2SecretAction;

  bool get isMatchOver => _player1HP <= 0 || _player2HP <= 0;

  String get winnerTitle {
    if (_player1HP <= 0 && _player2HP <= 0) return "MUTUAL KNOCKOUT! DRAW!";
    if (_player1HP <= 0) return mode == GameMode.singlePlayer ? "AI WINS!" : "PLAYER 2 WINS!";
    if (_player2HP <= 0) return "PLAYER 1 WINS!";
    return "";
  }

  void chooseP1Action(KalariAction action) {
    if (_phase != KalariPhase.p1Choosing) return;
    _p1SecretAction = action;

    if (mode == GameMode.twoPlayer) {
      // Conceal choice and move to handoff phase
      _phase = KalariPhase.handoff;
    } else {
      // 1P Mode: AI selects simultaneously
      final aiAction = _ai.chooseAction(
        difficulty: difficulty,
        aiStamina: _player2Stamina,
        playerHistory: _player1History,
      );
      _p2SecretAction = aiAction;
      _ai.recordPlayerAction(action);
      _resolveCombat();
    }
  }

  void confirmHandoff() {
    if (_phase == KalariPhase.handoff) {
      _phase = KalariPhase.p2Choosing;
    }
  }

  void chooseP2Action(KalariAction action) {
    if (_phase != KalariPhase.p2Choosing) return;
    _p2SecretAction = action;
    _resolveCombat();
  }

  void _resolveCombat() {
    if (_p1SecretAction == null || _p2SecretAction == null) return;

    final p1 = _p1SecretAction!;
    final p2 = _p2SecretAction!;

    final result = KalariRoundResult.resolve(
      p1: p1,
      p2: p2,
      p1Stamina: _player1Stamina,
      p2Stamina: _player2Stamina,
    );

    _lastResult = result;
    _player1History.add(p1);
    _player2History.add(p2);

    // Apply HP and Stamina changes
    _player1HP = math.max(0, _player1HP - result.p1Damage);
    _player2HP = math.max(0, _player2HP - result.p2Damage);

    _player1Stamina = (_player1Stamina + result.p1StaminaDelta).clamp(0, 100);
    _player2Stamina = (_player2Stamina + result.p2StaminaDelta).clamp(0, 100);

    _phase = KalariPhase.revealing;
  }

  void advanceToNextRound() {
    if (isMatchOver) {
      _phase = KalariPhase.matchComplete;
    } else {
      _p1SecretAction = null;
      _p2SecretAction = null;
      _phase = KalariPhase.p1Choosing;
    }
  }

  void reset() {
    _player1HP = 100;
    _player2HP = 100;
    _player1Stamina = 100;
    _player2Stamina = 100;
    _p1SecretAction = null;
    _p2SecretAction = null;
    _lastResult = null;
    _player1History.clear();
    _player2History.clear();
    _ai.reset();
    _phase = KalariPhase.p1Choosing;
  }
}
