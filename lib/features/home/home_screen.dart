import 'package:flutter/material.dart';
import '../../core/models/game_info.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/coming_soon_sheet.dart';
import '../../core/widgets/kalikoot_header.dart';
import 'widgets/featured_game_card.dart';
import 'widgets/game_grid_card.dart';
import 'widgets/game_illustrations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();

  void _onGameSelected(GameInfo game) {
    if (game.isPlayable) {
      Navigator.of(context).pushNamed('/mode-select', arguments: game);
    } else {
      ComingSoonSheet.show(
        context,
        game,
        GameIllustration(gameId: game.id, size: 70),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredGame = GameInfo.allGames.firstWhere((g) => g.isFeatured);
    final gridGames = GameInfo.allGames;

    final uriyadiHigh = _storage.getHighScore('uriyadi');
    final goliHigh = _storage.getHighScore('goli_kali');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const KaliKootHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Game Card
                    FeaturedGameCard(
                      game: featuredGame,
                      onPlay: () => _onGameSelected(featuredGame),
                    ),

                    const SizedBox(height: 12),

                    // Section Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.coral,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ALL GAMES',
                            style: AppTypography.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${GameInfo.allGames.where((g) => g.isPlayable).length} PLAYABLE',
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Responsive 2-Column Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: gridGames.length,
                        itemBuilder: (context, index) {
                          final game = gridGames[index];
                          return GameGridCard(
                            game: game,
                            onTap: () => _onGameSelected(game),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Player / Records Strip (matching visual reference style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.primaryNavy, width: 2.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRecordBadge('URIYADI BEST', '$uriyadiHigh pts', AppColors.yellow),
                  _buildRecordBadge('GOLI BEST', '$goliHigh pts', AppColors.cyan),
                  _buildRecordBadge('OFFLINE', 'READY', AppColors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordBadge(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryNavy, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.mutedText,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
