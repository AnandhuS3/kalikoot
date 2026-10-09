import 'package:flutter/material.dart';

enum KalariAction {
  attack,
  block,
  dodge;

  String get label {
    switch (this) {
      case KalariAction.attack:
        return 'ATTACK';
      case KalariAction.block:
        return 'BLOCK';
      case KalariAction.dodge:
        return 'DODGE';
    }
  }

  int get staminaCost {
    switch (this) {
      case KalariAction.attack:
        return 20;
      case KalariAction.block:
        return 5;
      case KalariAction.dodge:
        return 15;
    }
  }

  IconData get icon {
    switch (this) {
      case KalariAction.attack:
        return Icons.flash_on_rounded;
      case KalariAction.block:
        return Icons.shield_rounded;
      case KalariAction.dodge:
        return Icons.fast_forward_rounded;
    }
  }
}

class KalariRoundResult {
  final KalariAction p1Action;
  final KalariAction p2Action;
  final int p1Damage;
  final int p2Damage;
  final int p1StaminaDelta;
  final int p2StaminaDelta;
  final String summary;

  const KalariRoundResult({
    required this.p1Action,
    required this.p2Action,
    required this.p1Damage,
    required this.p2Damage,
    required this.p1StaminaDelta,
    required this.p2StaminaDelta,
    required this.summary,
  });

  static KalariRoundResult resolve({
    required KalariAction p1,
    required KalariAction p2,
    required int p1Stamina,
    required int p2Stamina,
  }) {
    int p1Dmg = 0;
    int p2Dmg = 0;
    int p1StamDelta = -p1.staminaCost;
    int p2StamDelta = -p2.staminaCost;
    String desc = '';

    final p1AttackPower = p1Stamina >= 20 ? 25 : 12; // Weakened if low stamina
    final p2AttackPower = p2Stamina >= 20 ? 25 : 12;

    if (p1 == KalariAction.attack && p2 == KalariAction.attack) {
      // Clash: Both deal damage
      p1Dmg = p2AttackPower;
      p2Dmg = p1AttackPower;
      desc = 'Fierce weapon clash! Both fighters strike!';
    } else if (p1 == KalariAction.attack && p2 == KalariAction.block) {
      // P2 blocks P1's attack
      p1Dmg = 0;
      p2Dmg = 0;
      p2StamDelta += 15; // Defender recovers stamina on successful block
      desc = 'P2 absorbs the blow with an iron shield!';
    } else if (p1 == KalariAction.attack && p2 == KalariAction.dodge) {
      // P2 dodges P1's attack
      p1Dmg = 0;
      p2Dmg = 0;
      p2StamDelta += 10;
      desc = 'P2 dodges gracefully! P1 lunges into empty air!';
    } else if (p1 == KalariAction.block && p2 == KalariAction.attack) {
      // P1 blocks P2's attack
      p1Dmg = 0;
      p2Dmg = 0;
      p1StamDelta += 15;
      desc = 'P1 deflects the strike completely!';
    } else if (p1 == KalariAction.dodge && p2 == KalariAction.attack) {
      // P1 dodges P2's attack
      p1Dmg = 0;
      p2Dmg = 0;
      p1StamDelta += 10;
      desc = 'P1 sidesteps swiftly! P2 misses!';
    } else if (p1 == KalariAction.block && p2 == KalariAction.block) {
      // Standoff
      p1StamDelta += 20;
      p2StamDelta += 20;
      desc = 'Cautious standoff. Both fighters catch their breath.';
    } else if (p1 == KalariAction.dodge && p2 == KalariAction.dodge) {
      // Double dodge
      p1StamDelta += 15;
      p2StamDelta += 15;
      desc = 'Both fighters leap back simultaneously!';
    } else if (p1 == KalariAction.block && p2 == KalariAction.dodge) {
      p1StamDelta += 15;
      p2StamDelta += 10;
      desc = 'Neutral repositioning.';
    } else if (p1 == KalariAction.dodge && p2 == KalariAction.block) {
      p1StamDelta += 10;
      p2StamDelta += 15;
      desc = 'Neutral repositioning.';
    }

    return KalariRoundResult(
      p1Action: p1,
      p2Action: p2,
      p1Damage: p1Dmg,
      p2Damage: p2Dmg,
      p1StaminaDelta: p1StamDelta,
      p2StaminaDelta: p2StamDelta,
      summary: desc,
    );
  }
}
