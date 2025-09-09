import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaguesApiService {
  final String _baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> fetchLeagues() async {
    try {
      final url = Uri.parse('$_baseUrl/popular_leagues');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> leaguesData = [];

        if (responseData['data'] != null &&
            responseData['data']['leagues'] != null) {
          leaguesData = responseData['data']['leagues'];
        } else if (responseData['leagues'] != null) {
          leaguesData = responseData['leagues'];
        } else if (responseData['data'] is List) {
          leaguesData = responseData['data'];
        }

        return leaguesData.map<Map<String, dynamic>>((league) {
          final name = league['sport_title'] ?? 'Unknown League';
          final sport = league['sport_group'] ?? 'Unknown Sport';
          final season = '2024';

          final imagePath = 'assets/leagues/$name.png';

          return {
            'name': name,
            'image': imagePath,
            'season': season,
            'sport': sport,
          };
        }).toList();
      }
    } catch (e) {
      // print(e);
      // API call failed, continue to fallback
    }

    // Return diverse leagues from different sports
    return [
      {
        'name': 'La Liga',
        'image': 'assets/leagues/La Liga.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'Serie A',
        'image': 'assets/leagues/Serie A.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'Bundesliga',
        'image': 'assets/leagues/Bundesliga.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'NBA',
        'image': 'assets/leagues/NBA.png',
        'season': '2024',
        'sport': 'Basketball',
      },
      {
        'name': 'NFL',
        'image': 'assets/leagues/NFL.png',
        'season': '2024',
        'sport': 'Football',
      },
    ];
  }
}
