class TeamModel {
  final int id;
  final String name;
  final String logo;
  final String color;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int ties;
  final int points;
  final int totalRunsScored;
  final double totalOversFaced;
  final int totalRunsConceded;
  final double totalOversBowled;
  final double netRunRate;

  final List<PlayerModel> players;
  final List<OwnerModel> owners;
  final List<CoachModel> coaches;

  TeamModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.color,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.points,
    required this.totalRunsScored,
    required this.totalOversFaced,
    required this.totalRunsConceded,
    required this.totalOversBowled,
    required this.netRunRate,
    required this.players,
    required this.owners,
    required this.coaches,
  });

  // --- helpers ---
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0.0;
    return 0.0;
  }

  static String _asStr(dynamic v) => (v ?? '').toString();

  static T _firstNonNull<T>(List<dynamic> candidates, T fallback) {
    for (final c in candidates) {
      if (c != null) return c as T;
    }
    return fallback;
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    // Allow common aliases from various APIs
    final mp = _firstNonNull<int>([
      json['matches_played'],
      json['played'],
      json['matches'],
      json['p'],
    ], 0);

    final nrr = _firstNonNull<dynamic>([
      json['net_run_rate'],
      json['nrr'],
      json['netRunRate'],
    ], 0.0);

    final wins = _firstNonNull<dynamic>([json['wins'], json['w']], 0);
    final losses = _firstNonNull<dynamic>([json['losses'], json['l']], 0);
    final ties =
        _firstNonNull<dynamic>([json['ties'], json['t'], json['draws']], 0);
    final pts = _firstNonNull<dynamic>([json['points'], json['pts']], 0);

    final trScored = _firstNonNull<dynamic>([
      json['total_runs_scored'],
      json['runs_for'],
      json['rf'],
      json['for'],
    ], 0);

    final toFaced = _firstNonNull<dynamic>([
      json['total_overs_faced'],
      json['overs_faced'],
      json['of'],
    ], 0.0);

    final trConceded = _firstNonNull<dynamic>([
      json['total_runs_conceded'],
      json['runs_against'],
      json['ra'],
      json['against'],
    ], 0);

    final toBowled = _firstNonNull<dynamic>([
      json['total_overs_bowled'],
      json['overs_bowled'],
      json['ob'],
    ], 0.0);

    final playersJson =
        (json['players'] is List) ? json['players'] as List : const [];
    final ownersJson =
        (json['owners'] is List) ? json['owners'] as List : const [];
    final coachesJson =
        (json['coaches'] is List) ? json['coaches'] as List : const [];

    return TeamModel(
      id: _asInt(json['id']),
      name: _asStr(json['name']),
      logo: _asStr(json['logo']),
      color: _asStr(json['color']),
      matchesPlayed: _asInt(mp),
      wins: _asInt(wins),
      losses: _asInt(losses),
      ties: _asInt(ties),
      points: _asInt(pts),
      totalRunsScored: _asInt(trScored),
      totalOversFaced: _asDouble(toFaced),
      totalRunsConceded: _asInt(trConceded),
      totalOversBowled: _asDouble(toBowled),
      netRunRate: _asDouble(nrr),
      players: playersJson
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      owners: ownersJson
          .map((e) => OwnerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      coaches: coachesJson
          .map((e) => CoachModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlayerModel {
  final int id;
  final String name;
  final String role;
  final String imageUrl;
  final String category;
  final String teamName;
  final int runs;
  final int matches;
  final int innings;
  final int notOuts;
  final String highestScore;
  final double average;
  final int ballsFaced;
  final double strikeRate;
  final int hundreds;
  final int fifties;
  final int fours;
  final int sixes;

  PlayerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.category,
    required this.teamName,
    required this.runs,
    required this.matches,
    required this.innings,
    required this.notOuts,
    required this.highestScore,
    required this.average,
    required this.ballsFaced,
    required this.strikeRate,
    required this.hundreds,
    required this.fifties,
    required this.fours,
    required this.sixes,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0.0;
    return 0.0;
  }

  static String _asStr(dynamic v) => (v ?? '').toString();

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: _asInt(json['id']),
      name: _asStr(json['name']),
      role: _asStr(json['role']),
      imageUrl: _asStr(json['image_url'] ?? json['imageUrl']),
      category: _asStr(json['category']),
      teamName: _asStr(json['team_name'] ?? json['teamName']),
      runs: _asInt(json['runs']),
      matches: _asInt(json['matches']),
      innings: _asInt(json['innings']),
      notOuts: _asInt(json['not_outs'] ?? json['notOuts']),
      highestScore: _asStr(json['highest_score'] ?? json['hs']),
      average: _asDouble(json['average']),
      ballsFaced: _asInt(json['balls_faced'] ?? json['bf']),
      strikeRate: _asDouble(json['strike_rate'] ?? json['sr']),
      hundreds: _asInt(json['hundreds'] ?? json['100s']),
      fifties: _asInt(json['fifties'] ?? json['50s']),
      fours: _asInt(json['fours']),
      sixes: _asInt(json['sixes']),
    );
  }
}

class OwnerModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int team;

  OwnerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.team,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static String _asStr(dynamic v) => (v ?? '').toString();

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: _asInt(json['id']),
      name: _asStr(json['name']),
      description: _asStr(json['description']),
      imageUrl: _asStr(json['image_url'] ?? json['imageUrl']),
      team: _asInt(json['team']),
    );
  }
}

class CoachModel {
  final int id;
  final String name;
  final String imageUrl;
  final int team;

  CoachModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.team,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static String _asStr(dynamic v) => (v ?? '').toString();

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: _asInt(json['id']),
      name: _asStr(json['name']),
      imageUrl: _asStr(json['image_url'] ?? json['imageUrl']),
      team: _asInt(json['team']),
    );
  }
}
