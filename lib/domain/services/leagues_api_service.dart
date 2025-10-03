import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class LeaguesApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchLeagues() async {
    try {
      final url = Uri.parse('$_baseUrl/popular_leagues');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>?;

        if (data != null && data['sports'] != null) {
          final sports = data['sports'] as List<dynamic>;
          final List<Map<String, dynamic>> allLeagues = [];

          for (final sport in sports) {
            final hasLeague = sport['has_league'] as List<dynamic>?;

            if (hasLeague != null) {
              for (final league in hasLeague) {
                final name = league['league_name'] ?? 'Unknown League';
                final country = league['league_country'] ?? 'Unknown';
                final imagePath = league['league_badge'] as String? ?? '';

                allLeagues.add({
                  'name': name,
                  'image': imagePath,
                  'sport': sport['sport_name'] ?? 'Unknown Sport',
                  'country': country,
                });
              }
            }
          }

          return allLeagues;
        }
      }
    } catch (e) {
      // Error fetching leagues: $e
    }

    // Return diverse leagues from different sports
    return [
      {
        'name': 'La Liga',
        'image': 'assets/leagues/La Liga.png',
        'sport': 'Soccer',
      },
      {
        'name': 'Serie A',
        'image': 'assets/leagues/Serie A.png',
        'sport': 'Soccer',
      },
      {
        'name': 'Bundesliga',
        'image': 'assets/leagues/Bundesliga.png',
        'sport': 'Soccer',
      },
      {'name': 'NBA', 'image': 'assets/leagues/NBA.png', 'sport': 'Basketball'},
      {'name': 'NFL', 'image': 'assets/leagues/NFL.png', 'sport': 'Football'},
      {
        'name': 'WNBA',
        'image': 'assets/leagues/WNBA.png',
        'sport': 'Basketball',
      },
    ];
  }
}
