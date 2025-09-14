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
    debugPrint("=== SAVE USER DATA ===");
    debugPrint("PublicKey: $publicKey");
    debugPrint("Address: $address");
    try {
      final url = Uri.parse('$_baseUrl/users');
      debugPrint("POST request to: $url");
      debugPrint("Request body: ${jsonEncode({
        'public_key': publicKey,
        'image_url': imageUrl,
        'address': address,
      })}");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'public_key': publicKey,
          'image_url': imageUrl,
          'address': address,
        }),
      );
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('User data saved successfully');
        debugPrint("=== SAVE USER DATA SUCCESS ===");
        return true;
      } else {
        debugPrint('Failed to save user data: ${response.statusCode} - ${response.body}');
        debugPrint("=== SAVE USER DATA FAILED ===");
        return false;
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      debugPrint("=== SAVE USER DATA ERROR ===");
      return false;
    }
  }

  Future<bool> checkUserExists(String userId) async {
    debugPrint("=== CHECK USER EXISTS ===");
    debugPrint("UserId: $userId");
    try {
      final url = Uri.parse('$_baseUrl/users/$userId');
      debugPrint("GET request to: $url");
      final response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("User exists in backend");
        debugPrint("=== CHECK USER EXISTS SUCCESS ===");
        return true;
      } else if (response.statusCode == 404) {
        debugPrint("User does not exist in backend");
        debugPrint("=== CHECK USER EXISTS NOT FOUND ===");
        return false;
      } else {
        debugPrint('Failed to check user existence: ${response.statusCode} - ${response.body}');
        debugPrint("=== CHECK USER EXISTS ERROR ===");
        return false;
      }
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      debugPrint("=== CHECK USER EXISTS ERROR ===");
      return false;
    }
  }

  Future<bool> recreateUserIfNeeded(String userId) async {
    debugPrint("=== RECREATE USER IF NEEDED ===");
    debugPrint("UserId: $userId");

    // First check if user exists
    final exists = await checkUserExists(userId);
    if (exists) {
      debugPrint("User already exists in backend - no recreation needed");
      debugPrint("=== RECREATE USER IF NEEDED: ALREADY EXISTS ===");
      return true;
    }

    debugPrint("User does not exist - attempting recreation...");

    try {
      // Get stored user data
      final prefs = await SharedPreferences.getInstance();
      final privateKey = prefs.getString('privateKey');
      final profileImage = prefs.getString('profileImage') ?? '';
      final email = prefs.getString('email') ?? '';
      final name = prefs.getString('name') ?? '';

      if (privateKey == null || privateKey.isEmpty) {
        debugPrint("No private key available for user recreation");
        debugPrint("=== RECREATE USER IF NEEDED: NO PRIVATE KEY ===");
        return false;
      }

      debugPrint("Recreating user with stored data:");
      debugPrint("  - Profile Image: $profileImage");
      debugPrint("  - Email: $email");
      debugPrint("  - Name: $name");

      final success = await saveUserData(
        publicKey: userId,
        imageUrl: profileImage,
        address: userId,
      );

      if (success) {
        debugPrint("Successfully recreated user in backend");
        debugPrint("=== RECREATE USER IF NEEDED: SUCCESS ===");
      } else {
        debugPrint("Failed to recreate user in backend");
        debugPrint("=== RECREATE USER IF NEEDED: FAILED ===");
      }

      return success;
    } catch (e) {
      debugPrint('Error recreating user: $e');
      debugPrint("=== RECREATE USER IF NEEDED: ERROR ===");
      return false;
    }
  }

  Future<List<String>> fetchFavorites(String userId) async {
    debugPrint("=== FETCH FAVORITES ===");
    debugPrint("UserId: $userId");
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      debugPrint("Fetching favorites from: $url");
      final response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint("Favorites response: ${response.body}");
        final List<dynamic> users = responseData['data']['user'] ?? [];
        final List<dynamic> favorites = users.isNotEmpty ? users[0]['favorites'] ?? [] : [];
        final eventIds = favorites.map<String>((fav) => fav['event_id'] as String).toList();
        debugPrint("Parsed eventIds: $eventIds");
        debugPrint("=== FETCH FAVORITES SUCCESS ===");
        return eventIds;
      } else {
        debugPrint('Failed to fetch favorites: ${response.statusCode} - ${response.body}');
        debugPrint("=== FETCH FAVORITES FAILED ===");
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      debugPrint("=== FETCH FAVORITES ERROR ===");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchFullFavorites(String userId) async {
    debugPrint("=== FETCH FULL FAVORITES ===");
    debugPrint("UserId: $userId");
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      debugPrint("Fetching full favorites from: $url");
      final response = await http.get(url);
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint("Full favorites response: ${response.body}");
        final List<dynamic> users = responseData['data']['user'] ?? [];
        final List<dynamic> favorites = users.isNotEmpty ? users[0]['favorites'] ?? [] : [];
        final fullFavorites = favorites.map<Map<String, dynamic>>((fav) => fav as Map<String, dynamic>).toList();
        debugPrint("Parsed full favorites: ${fullFavorites.length} items");
        debugPrint("=== FETCH FULL FAVORITES SUCCESS ===");
        return fullFavorites;
      } else {
        debugPrint('Failed to fetch full favorites: ${response.statusCode} - ${response.body}');
        debugPrint("=== FETCH FULL FAVORITES FAILED ===");
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching full favorites: $e');
      debugPrint("=== FETCH FULL FAVORITES ERROR ===");
      return [];
    }
  }

  Future<bool> addFavorite(String userId, String eventId) async {
    debugPrint("=== ADD FAVORITE ===");
    debugPrint("UserId: $userId");
    debugPrint("EventId: $eventId");
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites');
      debugPrint("POST request to: $url");
      debugPrint("Request body: ${jsonEncode({'event_id': eventId})}");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': eventId}),
      );
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Favorite added successfully');
        debugPrint("=== ADD FAVORITE SUCCESS ===");
        return true;
      } else {
        debugPrint('Failed to add favorite: ${response.statusCode} - ${response.body}');
        debugPrint("=== ADD FAVORITE FAILED ===");
        return false;
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      debugPrint("=== ADD FAVORITE ERROR ===");
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String eventId) async {
    debugPrint("=== REMOVE FAVORITE ===");
    debugPrint("UserId: $userId");
    debugPrint("EventId: $eventId");
    try {
      final url = Uri.parse('$_baseUrl/users/$userId/favorites/$eventId');
      debugPrint("DELETE request to: $url");
      final response = await http.delete(url);
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Favorite removed successfully');
        debugPrint("=== REMOVE FAVORITE SUCCESS ===");
        return true;
      } else {
        debugPrint('Failed to remove favorite: ${response.statusCode} - ${response.body}');
        debugPrint("=== REMOVE FAVORITE FAILED ===");
        return false;
      }
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      debugPrint("=== REMOVE FAVORITE ERROR ===");
      return false;
    }
  }
}