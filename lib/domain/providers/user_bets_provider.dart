import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bets_api_service.dart';

final betsApiServiceProvider = Provider<BetsApiService>((ref) {
  return BetsApiService();
});

final userBetsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final service = ref.read(betsApiServiceProvider);
  return await service.fetchUserBets(userId);
});