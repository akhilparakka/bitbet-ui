import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/team_model.dart';

class TeamApiService {
  // Update this to your actual API URL
  static const String baseUrl = 'http://localhost:3000';

  Future<List<TeamModel>> getTeams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> teamsJson = jsonData['data']['teams'];

        return teamsJson
            .map((json) => TeamModel.fromJson(json))
            .toList();
      } else {
        debugPrint('Failed to load teams: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching teams: $e');
      return [];
    }
  }
}
