import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';

class EventApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>?> fetchEventDetails(String eventId) async {
    try {
      final url = Uri.parse('$_baseUrl/events/$eventId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['data'] != null &&
            responseData['data']['events'] != null &&
            (responseData['data']['events'] as List).isNotEmpty) {
          return responseData['data']['events'][0] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
    return null;
  }
}
