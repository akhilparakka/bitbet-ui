class BetModel {
  final String id;
  final String eventId;
  final int outcomeIndex;
  final String type;
  final String shares;
  final String costOrProfit;
  final String fees;
  final String blockTimestamp;
  final String transactionHash;

  BetModel({
    required this.id,
    required this.eventId,
    required this.outcomeIndex,
    required this.type,
    required this.shares,
    required this.costOrProfit,
    required this.fees,
    required this.blockTimestamp,
    required this.transactionHash,
  });

  factory BetModel.fromJson(Map<String, dynamic> json) {
    return BetModel(
      id: json['id'] ?? '',
      eventId: json['market']?['eventId'] ?? '',
      outcomeIndex: json['outcomeIndex'] ?? 0,
      type: json['type'] ?? '',
      shares: json['shares'] ?? '0',
      costOrProfit: json['costOrProfit'] ?? '0',
      fees: json['fees'] ?? '0',
      blockTimestamp: json['blockTimestamp'] ?? '0',
      transactionHash: json['transactionHash'] ?? '',
    );
  }
}