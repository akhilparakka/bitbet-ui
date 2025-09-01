import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/leagues_api_service.dart';

final leaguesApiServiceProvider = Provider<LeaguesApiService>((ref) {
  return LeaguesApiService();
});

final leaguesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(leaguesApiServiceProvider);
  final leagues = await service.fetchLeagues();

  // Return all leagues since it's a scrollable list
  return leagues;
});