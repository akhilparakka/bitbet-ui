import 'dart:convert';
import 'package:http/http.dart' as http;
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
      final key = data.keys.first;
      final leagues = data[key] as List<dynamic>;

      final List<Map<String, dynamic>> allEvents = [];
      for (final league in leagues) {
        final sportTitle = league['sport_title'] as String;
        final events = league['has_event'] as List<dynamic>;
        for (final event in events) {
          allEvents.add({'event': event, 'league': sportTitle});
        }
      }

      return allEvents.map<Map<String, dynamic>>((item) {
        final event = item['event'] as Map<String, dynamic>;
        final league = item['league'] as String;
        final homeTeam = event['home_team'] ?? 'Unknown Home Team';
        final awayTeam = event['away_team'] ?? 'Unknown Away Team';
        final commenceTime = event['commence_time'];

        final homeTeamLogo = homeTeam != 'Unknown Home Team'
            ? 'assets/images/${homeTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';
        final awayTeamLogo = awayTeam != 'Unknown Away Team'
            ? 'assets/images/${awayTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';

        final bookmakers = event['has_bookmaker'] as List<dynamic>?;
        Map<String, String> odds = {
          'home': 'N/A',
          'draw': 'N/A',
          'away': 'N/A',
        };
        if (bookmakers != null && bookmakers.isNotEmpty) {
          for (final bookmaker in bookmakers) {
            final markets = bookmaker['has_market'] as List<dynamic>?;
            if (markets != null) {
              for (final market in markets) {
                if (market['market_key'] == 'h2h') {
                  final outcomes = market['has_outcome'] as List<dynamic>?;
                  if (outcomes != null) {
                    for (final outcome in outcomes) {
                      final name = outcome['outcome_name'] as String?;
                      final price = outcome['outcome_price']?.toString();
                      if (name == homeTeam) {
                        odds['home'] = price ?? 'N/A';
                      } else if (name == awayTeam) {
                        odds['away'] = price ?? 'N/A';
                      } else if (name == 'Draw') {
                        odds['draw'] = price ?? 'N/A';
                      }
                    }
                  }
                  break;
                }
              }
            }
            if (odds['home'] != 'N/A' ||
                odds['draw'] != 'N/A' ||
                odds['away'] != 'N/A') {
              break;
            }
          }
        }

        return {
          'id': event['event_id'],
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'homeTeamLogo': homeTeamLogo,
          'awayTeamLogo': awayTeamLogo,
          'league': league,
          'odds': odds,
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
