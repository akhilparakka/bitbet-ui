import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_api_service.dart';

final eventApiServiceProvider = Provider<EventApiService>((ref) {
  return EventApiService();
});

final eventDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, eventId) async {
      final service = ref.read(eventApiServiceProvider);
      return await service.fetchEventDetails(eventId);
    });

final teamFormProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  eventId,
) async {
  final service = ref.read(eventApiServiceProvider);
  return await service.fetchTeamForm(eventId);
});

final eventPricingProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, eventId) async {
      final service = ref.read(eventApiServiceProvider);
      return await service.fetchEventPricing(eventId);
    });
