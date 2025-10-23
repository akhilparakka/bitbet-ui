class EventModel {
  final String eventId;
  final String eventName;
  final String eventDate;
  final bool completed;
  final List<Map<String, dynamic>> homeTeam;
  final List<Map<String, dynamic>> awayTeam;
  final List<String> outcomes;
  final String marketContractAddress;

  EventModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.completed,
    required this.homeTeam,
    required this.awayTeam,
    required this.outcomes,
    required this.marketContractAddress,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['event_id'] ?? '',
      eventName: json['event_name'] ?? '',
      eventDate: json['event_date'] ?? '',
      completed: json['completed'] ?? false,
      homeTeam: (json['home_team'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
      awayTeam: (json['away_team'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
      outcomes: (json['outcomes'] as List<dynamic>? ?? []).cast<String>(),
      marketContractAddress: json['market_contract_address'] ?? '',
    );
  }
}