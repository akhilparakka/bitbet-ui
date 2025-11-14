class TeamModel {
  final String teamCode;
  final String teamCountry;
  final int teamFounded;
  final int teamId;
  final int teamLeagueId;
  final String teamLogo;
  final String teamName;
  final bool teamNational;
  final int teamSeason;
  final int teamVenueId;
  final String teamVenueName;

  const TeamModel({
    required this.teamCode,
    required this.teamCountry,
    required this.teamFounded,
    required this.teamId,
    required this.teamLeagueId,
    required this.teamLogo,
    required this.teamName,
    required this.teamNational,
    required this.teamSeason,
    required this.teamVenueId,
    required this.teamVenueName,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamCode: json['team_code'] ?? '',
      teamCountry: json['team_country'] ?? '',
      teamFounded: json['team_founded'] ?? 0,
      teamId: json['team_id'] ?? 0,
      teamLeagueId: json['team_league_id'] ?? 0,
      teamLogo: json['team_logo'] ?? '',
      teamName: json['team_name'] ?? '',
      teamNational: json['team_national'] ?? false,
      teamSeason: json['team_season'] ?? 0,
      teamVenueId: json['team_venue_id'] ?? 0,
      teamVenueName: json['team_venue_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_code': teamCode,
      'team_country': teamCountry,
      'team_founded': teamFounded,
      'team_id': teamId,
      'team_league_id': teamLeagueId,
      'team_logo': teamLogo,
      'team_name': teamName,
      'team_national': teamNational,
      'team_season': teamSeason,
      'team_venue_id': teamVenueId,
      'team_venue_name': teamVenueName,
    };
  }
}
