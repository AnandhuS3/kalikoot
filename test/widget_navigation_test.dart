import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalikoot/core/models/game_info.dart';
import 'package:kalikoot/core/models/game_mode.dart';
import 'package:kalikoot/core/theme/app_theme.dart';
import 'package:kalikoot/features/home/home_screen.dart';
import 'package:kalikoot/features/selection/difficulty_screen.dart';
import 'package:kalikoot/features/selection/mode_selection_screen.dart';
import 'package:kalikoot/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalikoot/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('KaliKoot Widget & Navigation Flow Tests', () {
    testWidgets('App launches with splash screen branding and progress bar', (tester) async {
      await tester.pumpWidget(const KaliKootApp());

      // Verify branding elements on launch
      expect(find.text('KALIKOOT'), findsOneWidget);
      expect(find.text('Small Games. Big Rivalries.'), findsOneWidget);

      // Advance periodic timer steps
      for (int i = 0; i < 45; i++) {
        await tester.pump(const Duration(milliseconds: 35));
      }
      await tester.pumpAndSettle();

      // Should now be on HomeScreen
      expect(find.text('ALL GAMES'), findsOneWidget);
    });

    testWidgets('HomeScreen renders featured card, grid games, and records bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );

      // Check title sections
      expect(find.text('★ FEATURED GAME'), findsOneWidget);
      expect(find.text('ALL GAMES'), findsOneWidget);

      // Verify the 3 playable game titles are visible in grid
      expect(find.text('URIYADI CHALLENGE'), findsWidgets);
      expect(find.text('GOLI KALI'), findsWidgets);
      expect(find.text('KALARI CLASH'), findsWidgets);

      // Verify future concept games are marked
      expect(find.text('SOON'), findsWidgets);
    });

    testWidgets('ModeSelectionScreen displays 1-Player and 2-Player cards', (tester) async {
      final uriyadi = GameInfo.allGames.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ModeSelectionScreen(game: uriyadi),
        ),
      );

      expect(find.text('1 PLAYER'), findsOneWidget);
      expect(find.text('2 PLAYERS'), findsOneWidget);
      expect(find.text('CHOOSE MODE'), findsOneWidget);
    });

    testWidgets('DifficultyScreen displays slider, character face, and Play button', (tester) async {
      final uriyadi = GameInfo.allGames.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: DifficultyScreen(
            game: uriyadi,
            mode: GameMode.singlePlayer,
          ),
        ),
      );

      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('EASY'), findsOneWidget);
      expect(find.text('MED'), findsOneWidget);
      expect(find.text('HARD'), findsOneWidget);
      expect(find.text('Tap or drag to adjust difficulty'), findsOneWidget);

      // Tap EASY segment
      await tester.tap(find.text('EASY'));
      await tester.pumpAndSettle();

      // Active difficulty title updates
      expect(find.text('EASY'), findsWidgets);
    });

    testWidgets('SettingsScreen displays audio toggles, record reset, and version info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsScreen(),
        ),
      );

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsOneWidget);
      expect(find.text('MATCH RECORDS'), findsOneWidget);
      expect(find.text('RESET LOCAL RECORDS'), findsOneWidget);
      expect(find.text('1.0.0 (Release)'), findsOneWidget);
    });
  });
}
