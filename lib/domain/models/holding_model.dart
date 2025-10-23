class HoldingModel {
  final String eventId;
  final int outcomeIndex;
  final String shares;
  final String totalSpent;
  final String totalReceived;
  final bool isRedeemed;

  HoldingModel({
    required this.eventId,
    required this.outcomeIndex,
    required this.shares,
    required this.totalSpent,
    required this.totalReceived,
    required this.isRedeemed,
  });

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      eventId: json['market']?['eventId'] ?? '',
      outcomeIndex: json['outcomeIndex'] ?? 0,
      shares: json['shares'] ?? '0',
      totalSpent: json['totalSpent'] ?? '0',
      totalReceived: json['totalReceived'] ?? '0',
      isRedeemed: json['isRedeemed'] ?? false,
    );
  }
}