import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/models/difficulty.dart';
import 'core/models/game_info.dart';
import 'core/models/game_mode.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/selection/difficulty_screen.dart';
import 'features/selection/mode_selection_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'games/goli_kali/ui/goli_kali_screen.dart';
import 'games/kalari_clash/ui/kalari_screen.dart';
import 'games/uriyadi/ui/uriyadi_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for clean mobile game experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage preferences
  await StorageService().init();

  runApp(const KaliKootApp());
}

class KaliKootApp extends StatelessWidget {
  const KaliKootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaliKoot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());

          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());

          case '/mode-select':
            final game = settings.arguments as GameInfo;
            return MaterialPageRoute(
              builder: (_) => ModeSelectionScreen(game: game),
            );

          case '/difficulty-select':
            final args = settings.arguments as Map<String, dynamic>;
            final game = args['game'] as GameInfo;
            final mode = args['mode'] as GameMode;
            return MaterialPageRoute(
              builder: (_) => DifficultyScreen(game: game, mode: mode),
            );

          case '/game/uriyadi':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final mode = args['mode'] as GameMode? ?? GameMode.singlePlayer;
            final diff = args['difficulty'] as Difficulty? ?? Difficulty.medium;
            return MaterialPageRoute(
              builder: (_) => UriyadiScreen(mode: mode, difficulty: diff),
            );

          case '/game/goli-kali':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final mode = args['mode'] as GameMode? ?? GameMode.singlePlayer;
            final diff = args['difficulty'] as Difficulty? ?? Difficulty.medium;
            return MaterialPageRoute(
              builder: (_) => GoliKaliScreen(mode: mode, difficulty: diff),
            );

          case '/game/kalari-clash':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final mode = args['mode'] as GameMode? ?? GameMode.singlePlayer;
            final diff = args['difficulty'] as Difficulty? ?? Difficulty.medium;
            return MaterialPageRoute(
              builder: (_) => KalariClashScreen(mode: mode, difficulty: diff),
            );

          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
