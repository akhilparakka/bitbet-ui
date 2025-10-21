/// Model class for event contract addresses
class EventContracts {
  final String marketAddress;
  final String eventAddress;
  final String collateralTokenAddress;
  final String marketMakerAddress;
  final List<String> outcomes;

  EventContracts({
    required this.marketAddress,
    required this.eventAddress,
    required this.collateralTokenAddress,
    required this.marketMakerAddress,
    required this.outcomes,
  });

  factory EventContracts.fromJson(Map<String, dynamic> json) {
    return EventContracts(
      marketAddress: json['marketAddress'] as String,
      eventAddress: json['eventAddress'] as String,
      collateralTokenAddress: json['collateralTokenAddress'] as String,
      marketMakerAddress: json['marketMakerAddress'] as String,
      outcomes: (json['outcomes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketAddress': marketAddress,
      'eventAddress': eventAddress,
      'collateralTokenAddress': collateralTokenAddress,
      'marketMakerAddress': marketMakerAddress,
      'outcomes': outcomes,
    };
  }
}
