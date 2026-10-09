enum UriyadiState {
  ready,
  swinging,
  hitResult,
  cooldown,
  roundComplete,
}

enum HitQuality {
  perfect,
  great,
  good,
  miss;

  String get label {
    switch (this) {
      case HitQuality.perfect:
        return 'PERFECT!';
      case HitQuality.great:
        return 'GREAT!';
      case HitQuality.good:
        return 'GOOD';
      case HitQuality.miss:
        return 'MISS!';
    }
  }

  int get points {
    switch (this) {
      case HitQuality.perfect:
        return 100;
      case HitQuality.great:
        return 70;
      case HitQuality.good:
        return 40;
      case HitQuality.miss:
        return 0;
    }
  }
}
