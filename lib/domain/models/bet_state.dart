/// Enum representing the current status of a bet transaction
enum BetStatus {
  idle,
  fetchingContracts,
  checkingBalance,
  approvingToken,
  placingBet,
  confirming,
  success,
  error,
}

/// Model class for bet state
class BetState {
  final BetStatus status;
  final String? txHash;
  final String? errorMessage;
  final double? progress; // 0.0 to 1.0

  const BetState({
    required this.status,
    this.txHash,
    this.errorMessage,
    this.progress,
  });

  factory BetState.idle() {
    return const BetState(status: BetStatus.idle, progress: 0.0);
  }

  factory BetState.fetchingContracts() {
    return const BetState(status: BetStatus.fetchingContracts, progress: 0.1);
  }

  factory BetState.checkingBalance() {
    return const BetState(status: BetStatus.checkingBalance, progress: 0.2);
  }

  factory BetState.approvingToken() {
    return const BetState(status: BetStatus.approvingToken, progress: 0.4);
  }

  factory BetState.placingBet() {
    return const BetState(status: BetStatus.placingBet, progress: 0.6);
  }

  factory BetState.confirming() {
    return const BetState(status: BetStatus.confirming, progress: 0.8);
  }

  factory BetState.success(String txHash) {
    return BetState(status: BetStatus.success, txHash: txHash, progress: 1.0);
  }

  factory BetState.error(String errorMessage) {
    return BetState(
      status: BetStatus.error,
      errorMessage: errorMessage,
      progress: 0.0,
    );
  }

  BetState copyWith({
    BetStatus? status,
    String? txHash,
    String? errorMessage,
    double? progress,
  }) {
    return BetState(
      status: status ?? this.status,
      txHash: txHash ?? this.txHash,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  String get statusMessage {
    switch (status) {
      case BetStatus.idle:
        return 'Ready';
      case BetStatus.fetchingContracts:
        return 'Fetching contract info...';
      case BetStatus.checkingBalance:
        return 'Checking balance...';
      case BetStatus.approvingToken:
        return 'Approving USDC...';
      case BetStatus.placingBet:
        return 'Placing bet...';
      case BetStatus.confirming:
        return 'Confirming transaction...';
      case BetStatus.success:
        return 'Bet placed successfully!';
      case BetStatus.error:
        return errorMessage ?? 'An error occurred';
    }
  }
}
