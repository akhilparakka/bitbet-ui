import 'dart:convert';
import 'package:http/http.dart' as http;

class OddsApiService {
  final String _baseUrl = 'https://api.the-odds-api.com/v4';
  final String apiKey;

  OddsApiService({required this.apiKey});

  Future<List<Map<String, dynamic>>> fetchOdds(String sportKey) async {
    final url = Uri.parse(
      '$_baseUrl/sports/$sportKey/odds'
      '?apiKey=$apiKey&regions=uk&markets=h2h&oddsFormat=decimal',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map<Map<String, dynamic>>((match) {
        // Extract team and league data
        final homeTeam = match['home_team'] ?? 'Unknown Home Team';
        final awayTeam = match['away_team'] ?? 'Unknown Away Team';
        final league = match['sport_title'] ?? 'Unknown League';
        final commenceTime = match['commence_time'];

        // Generate logo paths
        final homeTeamLogo = homeTeam != 'Unknown Home Team'
            ? 'assets/images/${homeTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';
        final awayTeamLogo = awayTeam != 'Unknown Away Team'
            ? 'assets/images/${awayTeam.toLowerCase().replaceAll(" ", "_")}.png'
            : 'assets/images/default_team.png';

        // Extract odds from the first bookmaker
        final bookmakers = match['bookmakers'] as List<dynamic>?;
        Map<String, String> odds = {
          'home': 'N/A',
          'draw': 'N/A',
          'away': 'N/A',
        };
        if (bookmakers != null && bookmakers.isNotEmpty) {
          final markets = bookmakers[0]['markets'] as List<dynamic>?;
          if (markets != null && markets.isNotEmpty) {
            final outcomes = markets[0]['outcomes'] as List<dynamic>?;
            if (outcomes != null) {
              for (final outcome in outcomes) {
                final name = outcome['name'] as String?;
                final price = outcome['price']?.toString();
                if (name == homeTeam) {
                  odds['home'] = price ?? 'N/A';
                } else if (name == awayTeam) {
                  odds['away'] = price ?? 'N/A';
                } else if (name == 'Draw') {
                  odds['draw'] = price ?? 'N/A';
                }
              }
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
