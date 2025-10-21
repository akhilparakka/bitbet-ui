class TransactionPreview {
  final String eventName;
  final String betType; // 'Home', 'Draw', 'Away'
  final double betAmount;
  final double estimatedCost;
  final double maxCost;
  final double shares;
  final double potentialPayout;
  final double netProfit;

  // Contract details
  final String marketAddress;
  final String collateralTokenAddress;
  final String marketMakerAddress;

  // Gas details
  final int estimatedGas;
  final double gasPrice; // in Gwei
  final double estimatedGasCost; // in ETH

  // Token details
  final int decimals;
  final String tokenSymbol;

  const TransactionPreview({
    required this.eventName,
    required this.betType,
    required this.betAmount,
    required this.estimatedCost,
    required this.maxCost,
    required this.shares,
    required this.potentialPayout,
    required this.netProfit,
    required this.marketAddress,
    required this.collateralTokenAddress,
    required this.marketMakerAddress,
    required this.estimatedGas,
    required this.gasPrice,
    required this.estimatedGasCost,
    required this.decimals,
    this.tokenSymbol = 'USDT',
  });

  String get formattedBetAmount => betAmount.toStringAsFixed(2);
  String get formattedEstimatedCost => estimatedCost.toStringAsFixed(6);
  String get formattedMaxCost => maxCost.toStringAsFixed(6);
  String get formattedShares => shares.toStringAsFixed(4);
  String get formattedPotentialPayout => potentialPayout.toStringAsFixed(2);
  String get formattedNetProfit => netProfit.toStringAsFixed(2);
  String get formattedGasPrice => gasPrice.toStringAsFixed(2);
  String get formattedGasCost => estimatedGasCost.toStringAsFixed(6);

  String get shortMarketAddress =>
      '${marketAddress.substring(0, 6)}...${marketAddress.substring(marketAddress.length - 4)}';
  String get shortCollateralAddress =>
      '${collateralTokenAddress.substring(0, 6)}...${collateralTokenAddress.substring(collateralTokenAddress.length - 4)}';
  String get shortMarketMakerAddress =>
      '${marketMakerAddress.substring(0, 6)}...${marketMakerAddress.substring(marketMakerAddress.length - 4)}';
}
