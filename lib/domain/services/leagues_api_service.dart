import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class LeaguesApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchLeagues() async {
    try {
      final url = Uri.parse('$_baseUrl/popular_leagues');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

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

    // Return empty array if API fails (all league images come from API)
    return [];
  }
}
