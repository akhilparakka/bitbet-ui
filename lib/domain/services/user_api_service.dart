import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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

      debugPrint('=== USER API: Sending POST request to $url ===');
      debugPrint(
        'Request Body: ${jsonEncode({'public_key': publicKey, 'image_url': imageUrl, 'address': address})}',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'public_key': publicKey,
          'image_url': imageUrl,
          'address': address,
        }),
      );

      debugPrint(
        '=== USER API: Response Status Code: ${response.statusCode} ===',
      );
      debugPrint('=== USER API: Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('=== USER API: User created/updated successfully ===');
        return true;
      } else {
        debugPrint(
          '=== USER API ERROR: Failed with status ${response.statusCode} ===',
        );
        return false;
      }
    } catch (e) {
      debugPrint('=== USER API EXCEPTION: $e ===');
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
      // final email = prefs.getString('email') ?? '';
      // final name = prefs.getString('name') ?? '';

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
            ? (users[0]['has_favorite'] ?? users[0]['favorites'] ?? [])
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
      debugPrint('=== FETCH FULL FAVORITES: Sending GET request to $url ===');
      final response = await http.get(url);

      debugPrint(
        '=== FETCH FULL FAVORITES: Response Status Code: ${response.statusCode} ===',
      );
      debugPrint(
        '=== FETCH FULL FAVORITES: Response Body: ${response.body} ===',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> users = responseData['data']['user'] ?? [];
        final List<dynamic> favorites = users.isNotEmpty
            ? (users[0]['has_favorite'] ?? users[0]['favorites'] ?? [])
            : [];
        final fullFavorites = favorites.map<Map<String, dynamic>>((fav) {
          final favMap = fav as Map<String, dynamic>;
          // Add sport_group assuming all favorites are from Soccer (based on quick picks)
          favMap['sport_group'] = 'Soccer';
          return favMap;
        }).toList();
        debugPrint(
          '=== FETCH FULL FAVORITES: Parsed favorites: $fullFavorites ===',
        );
        return fullFavorites;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('=== FETCH FULL FAVORITES EXCEPTION: $e ===');
      return [];
    }
  }

  Future<bool> addFavorite(String userId, String eventId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      debugPrint('=== ADD FAVORITE: Sending POST request to $url ===');
      debugPrint('Request Body: ${jsonEncode({'event_id': eventId})}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': eventId}),
      );

      debugPrint(
        '=== ADD FAVORITE: Response Status Code: ${response.statusCode} ===',
      );
      debugPrint('=== ADD FAVORITE: Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('=== ADD FAVORITE EXCEPTION: $e ===');
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String eventId) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites/$eventId');
      debugPrint('=== REMOVE FAVORITE: Sending DELETE request to $url ===');

      final response = await http.delete(url);

      debugPrint(
        '=== REMOVE FAVORITE: Response Status Code: ${response.statusCode} ===',
      );
      debugPrint('=== REMOVE FAVORITE: Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('=== REMOVE FAVORITE EXCEPTION: $e ===');
      return false;
    }
  }
}
