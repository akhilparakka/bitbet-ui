import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/odds_api_service.dart';
import 'user_provider.dart';

final oddsApiServiceProvider = Provider<OddsApiService>((ref) {
  // No API key needed for the new endpoint
  return OddsApiService(apiKey: '');
});

final oddsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((
  ref,
  sportKey,
) async {
  final service = ref.read(oddsApiServiceProvider);
  final apiMatches = await service.fetchOdds(sportKey);

  // Filter valid matches and take first 4
  return apiMatches
      .where(
        (match) =>
            match['homeTeam'] != null &&
            match['awayTeam'] != null &&
            match['homeTeam'].isNotEmpty &&
            match['awayTeam'].isNotEmpty &&
            match['odds'] != null &&
            (match['odds'] as Map).isNotEmpty,
      )
      .take(4)
      .toList();
});

final quickPicsWithFavoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final matches = await ref.watch(oddsProvider('soccer_epl').future);
  final favorites = await ref.watch(favoritesProvider.future);

  return matches.map((match) {
    return {
      ...match,
      'isFavorite': favorites.contains(match['id']),
    };
  }).toList();
});
