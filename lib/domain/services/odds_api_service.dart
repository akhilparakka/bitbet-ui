import 'dart:convert';
import 'package:http/http.dart' as http;

class OddsApiService {
  final String _baseUrl = 'http://localhost:3000';
  final String apiKey;

  OddsApiService({this.apiKey = ''});

  Future<List<Map<String, dynamic>>> fetchOdds(String sportKey) async {
    final url = Uri.parse('$_baseUrl/quick_pics');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> eplData = responseData['data']['epl'];
      final List<dynamic> events = eplData.isNotEmpty ? eplData[0]['has_event'] : [];

      return events.map<Map<String, dynamic>>((event) {
        // Extract team and league data
        final homeTeam = event['home_team'] ?? 'Unknown Home Team';
        final awayTeam = event['away_team'] ?? 'Unknown Away Team';
        final league = 'EPL'; // From the structure, it's EPL
        final commenceTime = event['commence_time'];

        // Generate logo paths
        final homeTeamLogo = homeTeam != 'Unknown Home Team'
            ? 'assets/images/${homeTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';
        final awayTeamLogo = awayTeam != 'Unknown Away Team'
            ? 'assets/images/${awayTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';

        // Extract odds from the first bookmaker's h2h market
        final bookmakers = event['has_bookmaker'] as List<dynamic>?;
        Map<String, String> odds = {
          'home': 'N/A',
          'draw': 'N/A',
          'away': 'N/A',
        };
        if (bookmakers != null && bookmakers.isNotEmpty) {
          // Find the first bookmaker with h2h market
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
                  break; // Found h2h market, no need to check other markets
                }
              }
            }
            if (odds['home'] != 'N/A' || odds['draw'] != 'N/A' || odds['away'] != 'N/A') {
              break; // Found odds, no need to check other bookmakers
            }
          }
        }

        return {
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'homeTeamLogo': homeTeamLogo,
          'awayTeamLogo': awayTeamLogo,
          'league': league,
          'odds': odds,
          'isLive':
              commenceTime != null &&
              DateTime.parse(commenceTime).isBefore(DateTime.now()),
          'isFavorite': false,
        };
      }).toList();
    } else {
      throw Exception('Failed to load odds: ${response.body}');
    }
  }
}
