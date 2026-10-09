import 'dart:math' as math;
import '../../../core/models/difficulty.dart';
import 'kalari_action.dart';

class KalariAI {
  static final math.Random _random = math.Random();

  // Markov transition table: previousAction -> (nextAction -> count)
  final Map<KalariAction, Map<KalariAction, int>> _transitions = {
    KalariAction.attack: {
      KalariAction.attack: 1,
      KalariAction.block: 1,
      KalariAction.dodge: 1,
    },
    KalariAction.block: {
      KalariAction.attack: 1,
      KalariAction.block: 1,
      KalariAction.dodge: 1,
    },
    KalariAction.dodge: {
      KalariAction.attack: 1,
      KalariAction.block: 1,
      KalariAction.dodge: 1,
    },
  };

  KalariAction? _lastPlayerAction;

  void recordPlayerAction(KalariAction action) {
    if (_lastPlayerAction != null) {
      final map = _transitions[_lastPlayerAction!]!;
      map[action] = (map[action] ?? 0) + 1;
    }
    _lastPlayerAction = action;
  }

  KalariAction chooseAction({
    required Difficulty difficulty,
    required int aiStamina,
    required List<KalariAction> playerHistory,
  }) {
    switch (difficulty) {
      case Difficulty.easy:
        return _chooseEasy(aiStamina);
      case Difficulty.medium:
        return _chooseMedium(aiStamina, playerHistory);
      case Difficulty.hard:
        return _chooseHard(aiStamina, playerHistory);
    }
  }

  KalariAction _chooseEasy(int stamina) {
    // If stamina very low, favor block to recover
    if (stamina < 10 && _random.nextDouble() < 0.6) {
      return KalariAction.block;
    }
    const actions = KalariAction.values;
    return actions[_random.nextInt(actions.length)];
  }

  KalariAction _chooseMedium(int stamina, List<KalariAction> history) {
    if (stamina < 15) return KalariAction.block;

    if (history.isNotEmpty) {
      final lastMove = history.last;
      // If player just attacked, predict they might attack again or block
      if (lastMove == KalariAction.attack) {
        return _random.nextDouble() < 0.5 ? KalariAction.block : KalariAction.dodge;
      }
      // If player blocked, predict they will now attack
      if (lastMove == KalariAction.block) {
        return KalariAction.block;
      }
    }
    return KalariAction.values[_random.nextInt(3)];
  }

  KalariAction _chooseHard(int stamina, List<KalariAction> history) {
    if (stamina < 20) {
      // Must recover stamina
      return _random.nextDouble() < 0.7 ? KalariAction.block : KalariAction.dodge;
    }

    if (_lastPlayerAction != null) {
      // Look up Markov transition distribution given the player's last action
      final row = _transitions[_lastPlayerAction!]!;
      KalariAction predictedPlayerMove = KalariAction.attack;
      int highestFrequency = -1;

      for (final entry in row.entries) {
        if (entry.value > highestFrequency) {
          highestFrequency = entry.value;
          predictedPlayerMove = entry.key;
        }
      }

      // Select optimal counter without ever inspecting current player input!
      switch (predictedPlayerMove) {
        case KalariAction.attack:
          // Counter to Attack: Block or Dodge
          return _random.nextDouble() < 0.6 ? KalariAction.block : KalariAction.dodge;
        case KalariAction.block:
          // Player is likely defensive, attack or recover
          return stamina >= 30 ? KalariAction.attack : KalariAction.block;
        case KalariAction.dodge:
          // Player likely dodging, conserve stamina or attack
          return stamina >= 30 ? KalariAction.attack : KalariAction.dodge;
      }
    }

    return KalariAction.values[_random.nextInt(3)];
  }

  void reset() {
    _lastPlayerAction = null;
    for (final row in _transitions.values) {
      row[KalariAction.attack] = 1;
      row[KalariAction.block] = 1;
      row[KalariAction.dodge] = 1;
    }
  }
}
