import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaguesApiService {
  final String _baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> fetchLeagues() async {
    // Try to fetch from API first
    try {
      final url = Uri.parse('$_baseUrl/popular_leagues');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Try different possible response structures
        List<dynamic> leaguesData = [];

        if (responseData['data'] != null && responseData['data']['leagues'] != null) {
          leaguesData = responseData['data']['leagues'];
        } else if (responseData['leagues'] != null) {
          leaguesData = responseData['leagues'];
        } else if (responseData['data'] is List) {
          leaguesData = responseData['data'];
        }

        return leaguesData.map<Map<String, dynamic>>((league) {
          final name = league['sport_title'] ?? 'Unknown League';
          final sport = league['sport_group'] ?? 'Unknown Sport';
          final season = '2024'; // Default season since it's not in the API response

          // Generate image path based on league name
          final imagePath = 'assets/images/${name.toLowerCase().replaceAll(" ", "_").replaceAll("-", "_").replaceAll("'", "")}.png';

          return {
            'name': name,
            'image': imagePath,
            'season': season,
            'sport': sport,
          };
        }).toList();
      }
    } catch (e) {
      // API call failed, continue to fallback
    }

    // Return diverse leagues from different sports
    return [
      {
        'name': 'La Liga',
        'image': 'assets/images/la_liga.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'Serie A',
        'image': 'assets/images/serie_a.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'Bundesliga',
        'image': 'assets/images/bundesliga.png',
        'season': '2024',
        'sport': 'Soccer',
      },
      {
        'name': 'NBA',
        'image': 'assets/images/nba.png',
        'season': '2024',
        'sport': 'Basketball',
      },
      {
        'name': 'NFL',
        'image': 'assets/images/nfl.png',
        'season': '2024',
        'sport': 'Football',
      },
    ];
  }
}