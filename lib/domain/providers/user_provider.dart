import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_api_service.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService();
});

final userIdProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final address = prefs.getString('address');
  debugPrint("Retrieved address from SharedPreferences: $address");
  return address; // Return null if not logged in
});

final favoritesProvider = FutureProvider<List<String>>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  debugPrint("Fetching favorites for userId: $userId");
  if (userId == null) {
    return []; // No favorites if not logged in
  }
  final userService = ref.read(userApiServiceProvider);
  return userService.fetchFavorites(userId);
});