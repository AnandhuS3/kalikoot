# KaliKoot

**"Small Games. Big Rivalries."**

KaliKoot is an offline-first, casual mobile game collection inspired by Kerala’s traditional village games and festival rivalries.

---

## Games Included

### Playable Games
1. **Uriyadi Challenge**: Traditional swinging festival clay pot smashing. Hit the apex with perfect timing to crack the pot with splash and stick strike animations. Includes 1P (5 attempts, high scores) and 2P alternating turns.
2. **Goli Kali**: 2D glass marble shooting with impulse physics, elastic sphere collisions, rubber wall bounces, rolling friction, and drag slingshot controls. Knock target marbles into the marked central zone. Features Easy, Medium, and Hard (ghost-ball trajectory) AI.
3. **Kalari Clash**: Tactical anticipation duel inspired by Kalaripayattu. Choose Attack, Block, or Dodge under stamina constraints. Features 1P with Markov prediction AI and local 2P pass-and-play with concealed stances.

### Future Concepts ("Coming Soon")
4. **Vallamkali Dash** (Snake boat rhythm race)
5. **Pulikali Panic** (Tiger dance reflex tapping)
6. **Yakshi: Don't Look Back** (Moonlit village escape puzzle)
7. **Nagapadam** (Sacred knot board strategy)
8. **Monsoon Mayhem** (Kerala rainstorm survival)

---

## Design System

- **Palette**: Background `#EAF4FC`, Navy `#34396F`, Coral `#FF625F`, Cyan `#13BDE0`, Green `#78C943`, Yellow `#FFBF32`, Purple `#BC3DE3`, Dark Surface `#29213B`.
- **Aesthetic**: Confident navy borders, rounded chunky cards, custom vector illustrations drawn entirely via Flutter's `CustomPainter` (zero raster dependencies).
- **Difficulty Selection**: Dynamic reactive cartoon face avatar reflecting Easy, Medium, and Hard with 3-stop rounded slider.

---

## Testing & Quality

- **Unit & Widget Tests**: 30 passing automated tests covering physics, timing accuracy, combat matrices, AI solvers, and navigation flows.
- **Static Analysis**: Clean `dart analyze lib test` with 0 warnings and 0 errors.

Run tests:
```pwsh
flutter test
```

Run static analysis:
```pwsh
dart analyze lib test
```

---

## Running & Building for Android

### Run on Device or Emulator:
```pwsh
flutter run
```

### Build Release APK:
```pwsh
flutter build apk --release
```
Release binary output: `build/app/outputs/flutter-apk/app-release.apk`
