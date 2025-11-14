class LeagueModel {
  final String leagueCountryCode;
  final String leagueCountryFlag;
  final String leagueCountryName;
  final int leagueId;
  final String leagueLogo;
  final String leagueName;
  final int leagueSeason;
  final String leagueType;
  final bool seasonCurrent;
  final String seasonEnd;
  final String seasonStart;

  const LeagueModel({
    required this.leagueCountryCode,
    required this.leagueCountryFlag,
    required this.leagueCountryName,
    required this.leagueId,
    required this.leagueLogo,
    required this.leagueName,
    required this.leagueSeason,
    required this.leagueType,
    required this.seasonCurrent,
    required this.seasonEnd,
    required this.seasonStart,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      leagueCountryCode: json['league_country_code'] ?? '',
      leagueCountryFlag: json['league_country_flag'] ?? '',
      leagueCountryName: json['league_country_name'] ?? '',
      leagueId: json['league_id'] ?? 0,
      leagueLogo: json['league_logo'] ?? '',
      leagueName: json['league_name'] ?? '',
      leagueSeason: json['league_season'] ?? 0,
      leagueType: json['league_type'] ?? '',
      seasonCurrent: json['season_current'] ?? false,
      seasonEnd: json['season_end'] ?? '',
      seasonStart: json['season_start'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'league_country_code': leagueCountryCode,
      'league_country_flag': leagueCountryFlag,
      'league_country_name': leagueCountryName,
      'league_id': leagueId,
      'league_logo': leagueLogo,
      'league_name': leagueName,
      'league_season': leagueSeason,
      'league_type': leagueType,
      'season_current': seasonCurrent,
      'season_end': seasonEnd,
      'season_start': seasonStart,
    };
  }
}
