import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../models/bet_model.dart';
import '../models/holding_model.dart';
import '../models/event_model.dart';

class BetsApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> fetchUserBets(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/bets');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body)['data'];
      final user = data['user'];
      final events = data['events'] as Map<String, dynamic>;

      return {
        'bets': (user['bets'] as List<dynamic>? ?? []).map((b) => BetModel.fromJson(b)).toList(),
        'holdings': (user['holdings'] as List<dynamic>? ?? []).map((h) => HoldingModel.fromJson(h)).toList(),
        'events': events.map((k, v) => MapEntry(k, EventModel.fromJson(v))),
        'totals': {
          'totalBets': user['totalBets'] ?? '0',
          'totalSpent': user['totalSpent'] ?? '0',
          'totalReceived': user['totalReceived'] ?? '0',
        },
      };
    } catch (e) {
      throw Exception('Failed to fetch user bets: $e');
    }
  }
}