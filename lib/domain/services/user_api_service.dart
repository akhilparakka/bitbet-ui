import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UserApiService {
  final String _baseUrl = 'http://localhost:3000';

  Future<bool> saveUserData({
    required String publicKey,
    required String imageUrl,
    required String address,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'public_key': publicKey,
          'image_url': imageUrl,
          'address': address,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('User data saved successfully');
        return true;
      } else {
        debugPrint('Failed to save user data: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      return false;
    }
  }

  Future<List<String>> fetchFavorites(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> favorites = responseData['favorites'] ?? [];
        return favorites.map<String>((fav) => fav['event_id'] as String).toList();
      } else {
        debugPrint('Failed to fetch favorites: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      return [];
    }
  }

  Future<bool> addFavorite(String userId, String eventId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': eventId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Favorite added successfully');
        return true;
      } else {
        debugPrint('Failed to add favorite: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }
}