import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_api_service.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService();
});

final userIdProvider = FutureProvider<String?>((ref) async {
  debugPrint("=== USER ID PROVIDER ===");
  final prefs = await SharedPreferences.getInstance();
  final address = prefs.getString('address');
  final privateKey = prefs.getString('privateKey');

  debugPrint("SharedPreferences check:");
  debugPrint("  - Address: $address");
  debugPrint("  - PrivateKey exists: ${privateKey != null && privateKey.isNotEmpty}");

  if (address == null || address.isEmpty) {
    debugPrint("No user address found - user not logged in");
    debugPrint("=== USER ID PROVIDER: NOT LOGGED IN ===");
    return null;
  }

  if (privateKey == null || privateKey.isEmpty) {
    debugPrint("No private key found - invalid login state");
    debugPrint("=== USER ID PROVIDER: INVALID STATE ===");
    return null;
  }

  debugPrint("User is logged in with address: $address");
  debugPrint("=== USER ID PROVIDER: LOGGED IN ===");
  return address;
});

final userExistsProvider = FutureProvider<bool>((ref) async {
  debugPrint("=== USER EXISTS PROVIDER ===");
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    debugPrint("No userId available - user not logged in");
    debugPrint("=== USER EXISTS PROVIDER: NOT LOGGED IN ===");
    return false;
  }

  final userService = ref.read(userApiServiceProvider);
  final exists = await userService.checkUserExists(userId);
  debugPrint("User exists in backend: $exists");
  debugPrint("=== USER EXISTS PROVIDER: ${exists ? 'EXISTS' : 'NOT EXISTS'} ===");
  return exists;
});

final userRecreationProvider = FutureProvider<bool>((ref) async {
  debugPrint("=== USER RECREATION PROVIDER ===");
  final userId = await ref.watch(userIdProvider.future);

  if (userId == null) {
    debugPrint("No userId available - cannot recreate user");
    debugPrint("=== USER RECREATION PROVIDER: NO USER ===");
    return false;
  }

  final userService = ref.read(userApiServiceProvider);
  final success = await userService.recreateUserIfNeeded(userId);
  debugPrint("User recreation result: $success");
  debugPrint("=== USER RECREATION PROVIDER: ${success ? 'SUCCESS' : 'FAILED'} ===");
  return success;
});

final favoritesProvider = FutureProvider<List<String>>((ref) async {
  debugPrint("=== FAVORITES PROVIDER ===");
  final userId = await ref.watch(userIdProvider.future);
  debugPrint("Fetching favorites for userId: $userId");

  if (userId == null) {
    debugPrint("No userId available - returning empty favorites");
    debugPrint("=== FAVORITES PROVIDER: NO USER ===");
    return [];
  }

  final userService = ref.read(userApiServiceProvider);

  // Ensure user exists in backend before fetching favorites
  debugPrint("Ensuring user exists in backend...");
  final userRecreated = await userService.recreateUserIfNeeded(userId);
  if (!userRecreated) {
    debugPrint("Failed to ensure user exists in backend - favorites may not work");
    debugPrint("=== FAVORITES PROVIDER: USER ENSURANCE FAILED ===");
    return [];
  }

  debugPrint("User exists in backend - proceeding to fetch favorites");
  final favorites = await userService.fetchFavorites(userId);
  debugPrint("=== FAVORITES PROVIDER: SUCCESS ===");
  return favorites;
});