import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sports_api_service.dart';

final sportsApiServiceProvider = Provider<SportsApiService>((ref) {
  return SportsApiService();
});

final sportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(sportsApiServiceProvider);
  final sports = await service.fetchSports();

  // Return all sports since it's a scrollable list
  return sports;
});