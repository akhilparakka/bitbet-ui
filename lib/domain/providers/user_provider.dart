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
  final privateKey = prefs.getString('privateKey');

  debugPrint("  - Address: $address");
  if (address == null || address.isEmpty) {
    return null;
  }

  if (privateKey == null || privateKey.isEmpty) {
    return null;
  }

  return address;
});

final userExistsProvider = FutureProvider<bool>((ref) async {
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    return false;
  }

  final userService = ref.read(userApiServiceProvider);
  final exists = await userService.checkUserExists(userId);
  return exists;
});

final userRecreationProvider = FutureProvider<bool>((ref) async {
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    return false;
  }

  final userService = ref.read(userApiServiceProvider);
  final success = await userService.recreateUserIfNeeded(userId);
  return success;
});

final favoritesProvider = FutureProvider<List<String>>((ref) async {
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    return [];
  }

  final userService = ref.read(userApiServiceProvider);

  final userRecreated = await userService.recreateUserIfNeeded(userId);
  if (!userRecreated) {
    return [];
  }

  final favorites = await userService.fetchFavorites(userId);
  return favorites;
});

final fullFavoritesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    return [];
  }

  final userService = ref.read(userApiServiceProvider);

  // Ensure user exists in backend before fetching favorites
  final userRecreated = await userService.recreateUserIfNeeded(userId);
  if (!userRecreated) {
    return [];
  }

  final fullFavorites = await userService.fetchFullFavorites(userId);
  return fullFavorites;
});
