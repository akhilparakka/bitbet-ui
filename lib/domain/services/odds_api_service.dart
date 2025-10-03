import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class OddsApiService {
  final String _baseUrl = AppConfig.baseUrl;
  final String apiKey;

  OddsApiService({this.apiKey = ''});

  Future<List<Map<String, dynamic>>> fetchOdds({String? sportGroup}) async {
    final url = Uri.parse(
      '$_baseUrl/quick_pics${sportGroup != null ? '?sport_group=$sportGroup' : ''}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final data = responseData['data'] as Map<String, dynamic>;
      final sports = data['sports'] as List<dynamic>;

      final List<Map<String, dynamic>> allEvents = [];

      for (final sport in sports) {
        final hasLeague = sport['has_league'] as List<dynamic>?;

        if (hasLeague != null) {
          for (final league in hasLeague) {
            final leagueName =
                league['league_name'] as String? ?? 'Unknown League';
            final events = league['has_event'] as List<dynamic>?;

            if (events != null) {
              for (final event in events) {
                allEvents.add({'event': event, 'league': leagueName});
              }
            }
          }
        }
      }

      return allEvents.map<Map<String, dynamic>>((item) {
        final event = item['event'] as Map<String, dynamic>;
        final league = item['league'] as String;

        // Extract team names from nested arrays
        String homeTeam = 'Unknown Home Team';
        String awayTeam = 'Unknown Away Team';
        String? homeTeamLogo;
        String? awayTeamLogo;

        final homeTeamList = event['home_team'] as List<dynamic>?;
        if (homeTeamList != null && homeTeamList.isNotEmpty) {
          final homeTeamData = homeTeamList.first as Map<String, dynamic>;
          homeTeam = homeTeamData['team_name'] ?? 'Unknown Home Team';
        }

        final awayTeamList = event['away_team'] as List<dynamic>?;
        if (awayTeamList != null && awayTeamList.isNotEmpty) {
          final awayTeamData = awayTeamList.first as Map<String, dynamic>;
          awayTeam = awayTeamData['team_name'] ?? 'Unknown Away Team';
        }

        homeTeamLogo = event['home_team_logo'] as String?;
        awayTeamLogo = event['away_team_logo'] as String?;

        final commenceTime = event['commence_time'] ?? event['event_date'];

        // Note: odds data is not in the quick_pics response anymore
        Map<String, String> odds = {
          'home': 'N/A',
          'draw': 'N/A',
          'away': 'N/A',
        };

        return {
          'id': event['event_id']?.toString() ?? '',
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'homeTeamLogo': homeTeamLogo,
          'awayTeamLogo': awayTeamLogo,
          'league': league,
          'odds': odds,
          'commenceTime': commenceTime,
          'isLive':
              commenceTime != null &&
              DateTime.parse(commenceTime).isBefore(DateTime.now()),
        };
      }).toList();
    } else {
      throw Exception('Failed to load odds: ${response.body}');
    }
  }
}
