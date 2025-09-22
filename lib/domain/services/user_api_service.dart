import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class UserApiService {
  final String _baseUrl = AppConfig.baseUrl;

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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> recreateUserIfNeeded(String userId) async {
    final exists = await checkUserExists(userId);
    if (exists) {
      return true;
    }

    try {
      // Get stored user data
      final prefs = await SharedPreferences.getInstance();
      final privateKey = prefs.getString('privateKey');
      final profileImage = prefs.getString('profileImage') ?? '';
      final email = prefs.getString('email') ?? '';
      final name = prefs.getString('name') ?? '';

      if (privateKey == null || privateKey.isEmpty) {
        return false;
      }

      final success = await saveUserData(
        publicKey: userId,
        imageUrl: profileImage,
        address: userId,
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> fetchFavorites(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> users = responseData['data']['user'] ?? [];
        final List<dynamic> favorites = users.isNotEmpty
            ? users[0]['favorites'] ?? []
            : [];
        final eventIds = favorites
            .map<String>((fav) => fav['event_id'] as String)
            .toList();
        return eventIds;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchFullFavorites(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> users = responseData['data']['user'] ?? [];
        final List<dynamic> favorites = users.isNotEmpty
            ? users[0]['favorites'] ?? []
            : [];
        final fullFavorites = favorites
            .map<Map<String, dynamic>>((fav) => fav as Map<String, dynamic>)
            .toList();
        return fullFavorites;
      } else {
        return [];
      }
    } catch (e) {
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String eventId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites/$eventId');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
