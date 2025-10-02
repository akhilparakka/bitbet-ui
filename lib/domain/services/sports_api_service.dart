import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class SportsApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchSports() async {
    // Try to fetch from API first
    try {
      final url = Uri.parse('$_baseUrl/all_sports');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final data = responseData['data'] as Map<String, dynamic>?;

        if (data != null && data['sports'] != null) {
          final sports = data['sports'] as List<dynamic>;

          return sports.map<Map<String, dynamic>>((sport) {
            final sportName = sport['sport_name'] ?? 'Unknown Sport';
            final sportIcon = sport['sport_icon'] as String? ?? '';
            final leagueCount = sport['league_count'] ?? 0;

            return {
              'name': sportName,
              'image': sportIcon,
              'sport_group': sportName,
              'league_count': leagueCount,
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching sports: $e');
    }

    // Return default sports if API fails
    return [
      {'name': 'Tennis', 'image': 'assets/images/tennis.png', 'count': 2},
      {'name': 'Baseball', 'image': 'assets/images/baseball.png', 'count': 2},
      {'name': 'Hockey', 'image': 'assets/images/hockey.png', 'count': 4},
    ];
  }
}
