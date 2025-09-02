import 'dart:convert';
import 'package:http/http.dart' as http;

class SportsApiService {
  final String _baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> fetchSports() async {
    // Try to fetch from API first
    try {
      final url = Uri.parse('$_baseUrl/all_sports');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Parse the nested structure: data.unique_sports[0].@groupby
        List<dynamic> sportsData = [];
        if (responseData['data'] != null &&
            responseData['data']['unique_sports'] != null &&
            responseData['data']['unique_sports'].isNotEmpty) {
          final uniqueSports = responseData['data']['unique_sports'][0];
          if (uniqueSports['@groupby'] != null) {
            sportsData = uniqueSports['@groupby'];
          }
        }

        return sportsData.map<Map<String, dynamic>>((sport) {
          final sportGroup = sport['sport_group'] ?? 'Unknown Sport';
          final count = sport['count'] ?? 0;

          // Generate image path based on sport group
          final imagePath = 'assets/images/${sportGroup.toLowerCase().replaceAll(" ", "_").replaceAll("'", "")}.png';

          return {
            'name': sportGroup,
            'image': imagePath,
            'count': count,
          };
        }).toList();
      }
    } catch (e) {
      // API call failed, continue to fallback
    }

    // Return default sports if API fails
    return [
      {'name': 'Tennis', 'image': 'assets/images/tennis.png', 'count': 2},
      {'name': 'Baseball', 'image': 'assets/images/baseball.png', 'count': 2},
      {'name': 'Hockey', 'image': 'assets/images/hockey.png', 'count': 4},
    ];
  }
}