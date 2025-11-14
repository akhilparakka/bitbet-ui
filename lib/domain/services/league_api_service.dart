import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/league_model.dart';

class LeagueApiService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<LeagueModel>> getLeagues() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leagues'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> leaguesJson = jsonData['data']['leagues'];

        return leaguesJson.map((json) => LeagueModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load leagues: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching leagues: $e');
      return [];
    }
  }
}
