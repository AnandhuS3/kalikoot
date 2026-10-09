import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum GameId {
  uriyadi,
  goliKali,
  kalariClash,
  vallamkali,
  pulikali,
  yakshi,
  nagapadam,
  monsoonMayhem,
}

class GameInfo {
  final GameId id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final Color accentColor;
  final bool isPlayable;
  final bool isFeatured;

  const GameInfo({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.accentColor,
    required this.isPlayable,
    this.isFeatured = false,
  });

  static const List<GameInfo> allGames = [
    GameInfo(
      id: GameId.uriyadi,
      title: 'Uriyadi Challenge',
      shortDescription: 'Swing and smash the suspended festival pot!',
      fullDescription:
          'Inspired by Kerala’s traditional Onam and Krishna Jayanthi festival activity. Time your strike to shatter the swinging clay pot at the perfect apex to score maximum points!',
      accentColor: AppColors.yellow,
      isPlayable: true,
      isFeatured: true,
    ),
    GameInfo(
      id: GameId.goliKali,
      title: 'Goli Kali',
      shortDescription: 'Classic glass marble tactical knockouts!',
      fullDescription:
          'Kerala’s beloved village marble game. Pull back, aim carefully, and release your glass marble with precise velocity to knock target marbles into the scoring ring!',
      accentColor: AppColors.cyan,
      isPlayable: true,
    ),
    GameInfo(
      id: GameId.kalariClash,
      title: 'Kalari Clash',
      shortDescription: 'Mind-game martial duels of Attack, Block & Dodge!',
      fullDescription:
          'A tactical anticipation showdown inspired by Kalaripayattu. Anticipate your rival’s secret stance, balance your stamina, and execute swift counters in 1P or 2P pass-and-play!',
      accentColor: AppColors.purple,
      isPlayable: true,
    ),
    GameInfo(
      id: GameId.vallamkali,
      title: 'Vallamkali Dash',
      shortDescription: 'Synchronized snake-boat rhythm racing!',
      fullDescription:
          'Tap in harmony to the boatman’s vanchipattu cadence and steer your Chundan Vallam through the backwater currents to victory.',
      accentColor: AppColors.green,
      isPlayable: false,
    ),
    GameInfo(
      id: GameId.pulikali,
      title: 'Pulikali Panic',
      shortDescription: 'Rhythmic tiger-dance reflex tapping!',
      fullDescription:
          'Match wild festival drumbeats, evade tricky hunters, and keep the roaring tiger dance alive through Swaraj Round!',
      accentColor: AppColors.coral,
      isPlayable: false,
    ),
    GameInfo(
      id: GameId.yakshi,
      title: "Yakshi: Don't Look Back",
      shortDescription: 'Eerie moonlit village escape puzzle!',
      fullDescription:
          'Navigate moonlit country lanes beneath fragrant pala trees. Keep your footsteps steady and never turn around when the bells chime.',
      accentColor: AppColors.primaryNavy,
      isPlayable: false,
    ),
    GameInfo(
      id: GameId.nagapadam,
      title: 'Nagapadam',
      shortDescription: 'Ancient sacred knot strategy board!',
      fullDescription:
          'A cerebral board game inspired by temple floor kalams. Weave serpentine trails and capture enemy nodes before the ring closes.',
      accentColor: AppColors.coral,
      isPlayable: false,
    ),
    GameInfo(
      id: GameId.monsoonMayhem,
      title: 'Monsoon Mayhem',
      shortDescription: 'Brave sudden Kerala torrential downpours!',
      fullDescription:
          'Hold your black palm-leaf umbrella against wild gusty raindrops, puddle splashes, and flying coconut leaves!',
      accentColor: AppColors.cyan,
      isPlayable: false,
    ),
  ];
}
