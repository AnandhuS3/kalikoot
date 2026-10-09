/// Represents player modes available in KaliKoot.
enum GameMode {
  singlePlayer,
  twoPlayer;

  String get label {
    switch (this) {
      case GameMode.singlePlayer:
        return '1 PLAYER';
      case GameMode.twoPlayer:
        return '2 PLAYERS';
    }
  }

  String get subtitle {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Play against computer';
      case GameMode.twoPlayer:
        return 'Play locally on one phone';
    }
  }
}
