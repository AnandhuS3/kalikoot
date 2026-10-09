import 'package:flutter_test/flutter_test.dart';
import 'package:kalikoot/core/models/difficulty.dart';
import 'package:kalikoot/core/models/game_mode.dart';
import 'package:kalikoot/games/kalari_clash/engine/kalari_action.dart';
import 'package:kalikoot/games/kalari_clash/engine/kalari_ai.dart';
import 'package:kalikoot/games/kalari_clash/engine/kalari_engine.dart';

void main() {
  group('Kalari Clash Combat Matrix & Engine Unit Tests', () {
    test('Attack vs Block: Block negates damage and defender recovers stamina', () {
      final res = KalariRoundResult.resolve(
        p1: KalariAction.attack,
        p2: KalariAction.block,
        p1Stamina: 100,
        p2Stamina: 100,
      );

      expect(res.p1Damage, equals(0));
      expect(res.p2Damage, equals(0));
      expect(res.p1StaminaDelta, equals(-20)); // Attack stamina cost
      expect(res.p2StaminaDelta, equals(10)); // -5 cost + 15 bonus = +10
    });

    test('Attack vs Dodge: Dodge avoids attack and leaves attacker spent', () {
      final res = KalariRoundResult.resolve(
        p1: KalariAction.attack,
        p2: KalariAction.dodge,
        p1Stamina: 100,
        p2Stamina: 100,
      );

      expect(res.p1Damage, equals(0));
      expect(res.p2Damage, equals(0));
      expect(res.p1StaminaDelta, equals(-20));
      expect(res.p2StaminaDelta, equals(-5)); // -15 cost + 10 bonus = -5
    });

    test('Attack vs Attack: Both fighters land damage', () {
      final res = KalariRoundResult.resolve(
        p1: KalariAction.attack,
        p2: KalariAction.attack,
        p1Stamina: 100,
        p2Stamina: 100,
      );

      expect(res.p1Damage, equals(25));
      expect(res.p2Damage, equals(25));
      expect(res.p1StaminaDelta, equals(-20));
      expect(res.p2StaminaDelta, equals(-20));
    });

    test('Low stamina reduces Attack damage', () {
      final res = KalariRoundResult.resolve(
        p1: KalariAction.attack,
        p2: KalariAction.attack,
        p1Stamina: 10, // Under 20 stamina threshold
        p2Stamina: 100,
      );

      // P1 only deals weakened 12 damage to P2, but takes full 25 from P2
      expect(res.p2Damage, equals(12));
      expect(res.p1Damage, equals(25));
    });

    test('Block vs Block: Standoff recovers stamina for both', () {
      final res = KalariRoundResult.resolve(
        p1: KalariAction.block,
        p2: KalariAction.block,
        p1Stamina: 50,
        p2Stamina: 50,
      );

      expect(res.p1Damage, equals(0));
      expect(res.p2Damage, equals(0));
      expect(res.p1StaminaDelta, equals(15)); // -5 + 20 = +15
      expect(res.p2StaminaDelta, equals(15));
    });

    test('2-Player Pass-and-Play conceals P1 selection until P2 confirms', () {
      final engine = KalariEngine(mode: GameMode.twoPlayer);

      expect(engine.phase, equals(KalariPhase.p1Choosing));

      // Player 1 chooses Attack secretly
      engine.chooseP1Action(KalariAction.attack);

      // Move is masked behind handoff phase
      expect(engine.phase, equals(KalariPhase.handoff));
      expect(engine.p1SecretAction, equals(KalariAction.attack));
      expect(engine.p2SecretAction, isNull);

      // Confirm handoff
      engine.confirmHandoff();
      expect(engine.phase, equals(KalariPhase.p2Choosing));

      // Player 2 chooses Block
      engine.chooseP2Action(KalariAction.block);

      // Both moves revealed together!
      expect(engine.phase, equals(KalariPhase.revealing));
      expect(engine.lastResult, isNotNull);
      expect(engine.lastResult!.p1Action, equals(KalariAction.attack));
      expect(engine.lastResult!.p2Action, equals(KalariAction.block));
    });

    test('Winner detection triggers when opponent HP drops to 0', () {
      final engine = KalariEngine(mode: GameMode.twoPlayer);

      // In 2P mode, both fighters attack each round, dealing 25 damage each
      while (!engine.isMatchOver) {
        engine.chooseP1Action(KalariAction.attack);
        engine.confirmHandoff();
        engine.chooseP2Action(KalariAction.attack);
        engine.advanceToNextRound();
      }

      expect(engine.isMatchOver, isTrue);
      expect(engine.winnerTitle, isNotEmpty);
    });

    test('Hard AI Markov transition model outputs legal actions without cheating', () {
      final ai = KalariAI();

      // Train AI that player frequently follows Attack with Attack
      for (int i = 0; i < 5; i++) {
        ai.recordPlayerAction(KalariAction.attack);
        ai.recordPlayerAction(KalariAction.attack);
      }

      final chosenAction = ai.chooseAction(
        difficulty: Difficulty.hard,
        aiStamina: 80,
        playerHistory: [KalariAction.attack],
      );

      // Should choose a valid legal counter (Block or Dodge)
      expect(
        chosenAction == KalariAction.block || chosenAction == KalariAction.dodge,
        isTrue,
      );
    });

    test('Reset restores 100 HP, 100 Stamina and clean state', () {
      final engine = KalariEngine();
      engine.chooseP1Action(KalariAction.attack);
      engine.advanceToNextRound();

      engine.reset();
      expect(engine.player1HP, equals(100));
      expect(engine.player2HP, equals(100));
      expect(engine.player1Stamina, equals(100));
      expect(engine.player2Stamina, equals(100));
      expect(engine.phase, equals(KalariPhase.p1Choosing));
      expect(engine.isMatchOver, isFalse);
    });
  });
}
