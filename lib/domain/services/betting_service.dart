import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction_preview.dart';

class BettingService {
  final Web3Client web3Client;
  final EthPrivateKey credentials;

  BettingService({required this.web3Client, required this.credentials});

  /// Simulate a bet transaction and return preview details
  Future<TransactionPreview> simulateBet({
    required String eventName,
    required String betType,
    required int outcomeIndex,
    required String betAmountUSDC,
    required double sharePrice,
    required String marketAddress,
    required String collateralTokenAddress,
    required String marketMakerAddress,
  }) async {
    try {
      // Load contract ABIs
      final marketAbi = await _loadAbi('StandardMarket.abi.json');
      final collateralAbi = await _loadAbi('ERC20.abi.json');
      final marketMakerAbi = await _loadAbi('LMSRMarketMaker.abi.json');

      // Create contract instances
      final marketContract = DeployedContract(
        ContractAbi.fromJson(marketAbi, 'StandardMarket'),
        EthereumAddress.fromHex(marketAddress),
      );

      final collateralToken = DeployedContract(
        ContractAbi.fromJson(collateralAbi, 'ERC20'),
        EthereumAddress.fromHex(collateralTokenAddress),
      );

      final marketMaker = DeployedContract(
        ContractAbi.fromJson(marketMakerAbi, 'LMSRMarketMaker'),
        EthereumAddress.fromHex(marketMakerAddress),
      );

      // Get token decimals
      final decimals = await _getDecimals(collateralToken);
      final betAmount = double.parse(betAmountUSDC);

      // Calculate shares from bet amount and share price
      // User wants to spend betAmount USDT, calculate how many shares they get
      final shares = betAmount / sharePrice;
      final sharesWei = BigInt.from(shares * pow(10, decimals));

      // Get price quote for the calculated shares
      final estimatedCost = await _getQuote(
        marketMaker,
        marketAddress,
        outcomeIndex,
        sharesWei, // Pass SHARES not betAmount
      );

      final maxCost = (estimatedCost * BigInt.from(105)) ~/ BigInt.from(100);

      // Calculate potential payout and profit
      final estimatedCostDecimal = estimatedCost.toDouble() / pow(10, decimals);
      final maxCostDecimal = maxCost.toDouble() / pow(10, decimals);
      final potentialPayout = shares; // Each share pays 1 USDT if it wins
      final netProfit =
          potentialPayout -
          estimatedCostDecimal; // Profit = payout - actual cost

      // Get gas price
      final gasPrice = await web3Client.getGasPrice();
      final gasPriceGwei = gasPrice.getInWei.toDouble() / 1e9;

      // Estimate gas (approve + buy)
      final estimatedGas = 100000 + 500000; // Approve + Buy
      final estimatedGasCost =
          (estimatedGas * gasPrice.getInWei.toDouble()) / 1e18;

      return TransactionPreview(
        eventName: eventName,
        betType: betType,
        betAmount: betAmount,
        estimatedCost: estimatedCostDecimal,
        maxCost: maxCostDecimal,
        shares: shares,
        potentialPayout: potentialPayout,
        netProfit: netProfit,
        marketAddress: marketAddress,
        collateralTokenAddress: collateralTokenAddress,
        marketMakerAddress: marketMakerAddress,
        estimatedGas: estimatedGas,
        gasPrice: gasPriceGwei,
        estimatedGasCost: estimatedGasCost,
        decimals: decimals,
      );
    } catch (e) {
      debugPrint('Error simulating bet: $e');
      rethrow;
    }
  }

  /// Main function to place a bet
  Future<String> buyOutcome({
    required String eventId,
    required int outcomeIndex, // 0=Home, 1=Draw, 2=Away
    required String
    betAmountUSDC, // "100" (human readable USDT amount user wants to spend)
    required double sharePrice, // Current share price from pricing API
    required String marketAddress,
    required String collateralTokenAddress,
    required String marketMakerAddress,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      // STEP 1: Contract addresses provided directly from frontend
      onStatusUpdate?.call('Loading contracts...');

      debugPrint('=== BETTING DEBUG ===');
      debugPrint('Event ID: $eventId');
      debugPrint('Outcome Index: $outcomeIndex');
      debugPrint('Bet Amount: $betAmountUSDC USDC');
      debugPrint('Market Address: $marketAddress');
      debugPrint('Collateral Address: $collateralTokenAddress');
      debugPrint('Market Maker Address: $marketMakerAddress');

      onStatusUpdate?.call('Loading contracts...');
      debugPrint('Loading ABIs...');
      final marketAbi = await _loadAbi('StandardMarket.abi.json');
      final collateralAbi = await _loadAbi('ERC20.abi.json');
      final marketMakerAbi = await _loadAbi('LMSRMarketMaker.abi.json');
      debugPrint('ABIs loaded successfully');

      debugPrint('Creating contract instances...');

      debugPrint('Creating market contract...');
      final marketContract = DeployedContract(
        ContractAbi.fromJson(marketAbi, 'StandardMarket'),
        EthereumAddress.fromHex(marketAddress),
      );
      debugPrint('Market contract created');

      debugPrint('Creating collateral token contract...');
      final collateralToken = DeployedContract(
        ContractAbi.fromJson(collateralAbi, 'ERC20'),
        EthereumAddress.fromHex(collateralTokenAddress),
      );
      debugPrint('Collateral token contract created');

      debugPrint('Creating market maker contract...');
      final marketMaker = DeployedContract(
        ContractAbi.fromJson(marketMakerAbi, 'LMSRMarketMaker'),
        EthereumAddress.fromHex(marketMakerAddress),
      );
      debugPrint('Market maker contract created');

      debugPrint('Getting token decimals...');
      final decimals = await _getDecimals(collateralToken);
      debugPrint('Token decimals: $decimals');

      final betAmount = double.parse(betAmountUSDC);
      debugPrint('User wants to spend: $betAmount USDC');
      debugPrint('Current share price: $sharePrice');

      // Calculate how many shares the user can buy
      final shares = betAmount / sharePrice;
      debugPrint('Calculated shares: $shares');

      final sharesWei = BigInt.from(shares * pow(10, decimals));
      debugPrint('Shares in wei: $sharesWei');

      onStatusUpdate?.call('Checking balance...');
      debugPrint('Getting user address...');
      final userAddress = await credentials.extractAddress();
      debugPrint('User address: ${userAddress.hex}');

      debugPrint('Checking balance...');
      final balance = await _getBalance(collateralToken, userAddress);
      debugPrint('User balance: $balance');

      // Check if balance covers rough estimate
      final roughEstimate = BigInt.from(betAmount * 1.1 * pow(10, decimals));
      if (balance < roughEstimate) {
        throw Exception(
          'Insufficient balance. You have ${balance / BigInt.from(pow(10, decimals))} USDC',
        );
      }

      // STEP 6: Get price quote for the shares
      debugPrint('Getting price quote for $shares shares...');
      final estimatedCost = await _getQuote(
        marketMaker,
        marketAddress,
        outcomeIndex,
        sharesWei,
      );

      debugPrint(
        'Estimated cost: ${estimatedCost / BigInt.from(pow(10, decimals))} USDC',
      );

      // Calculate maxCost with 5% slippage buffer
      final maxCost = (estimatedCost * BigInt.from(105)) ~/ BigInt.from(100);

      // STEP 7: Approve collateral token (if needed)
      final currentAllowance = await _getAllowance(
        collateralToken,
        userAddress,
        EthereumAddress.fromHex(marketAddress),
      );

      if (currentAllowance < maxCost) {
        onStatusUpdate?.call('Approving USDC...');
        debugPrint('Approving USDC...');
        await _approveToken(
          collateralToken,
          EthereumAddress.fromHex(marketAddress),
          maxCost, // Approve maxCost amount
        );
        debugPrint('Approval confirmed!');
      }

      // STEP 8: Place the bet

      onStatusUpdate?.call('Placing bet...');
      debugPrint('Placing bet with $shares shares...');
      final txHash = await _executeBuy(
        marketContract,
        outcomeIndex,
        sharesWei, // Pass SHARES, not betAmount
        maxCost,
        onStatusUpdate: onStatusUpdate,
      );

      debugPrint('Bet placed! Transaction: $txHash');
      return txHash;
    } catch (e) {
      debugPrint('Error placing bet: $e');
      rethrow;
    }
  }

  // ============ HELPER FUNCTIONS ============

  /// Load ABI from assets
  Future<String> _loadAbi(String filename) async {
    return await rootBundle.loadString('assets/frontend_abis/$filename');
  }

  /// Get token decimals
  Future<int> _getDecimals(DeployedContract token) async {
    try {
      debugPrint('Calling decimals() function...');
      final decimalsFunction = token.function('decimals');
      debugPrint('Function found: ${decimalsFunction.name}');

      final result = await web3Client
          .call(contract: token, function: decimalsFunction, params: [])
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'RPC call timeout - check if Anvil is accessible',
              );
            },
          );
      debugPrint('decimals() call result: $result');

      final decimals = (result.first as BigInt).toInt();
      debugPrint('Parsed decimals: $decimals');
      return decimals;
    } catch (e) {
      debugPrint('ERROR in _getDecimals: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Get token balance
  Future<BigInt> _getBalance(
    DeployedContract token,
    EthereumAddress address,
  ) async {
    final balanceFunction = token.function('balanceOf');
    final result = await web3Client.call(
      contract: token,
      function: balanceFunction,
      params: [address],
    );
    return result.first as BigInt;
  }

  /// Get price quote from market maker
  Future<BigInt> _getQuote(
    DeployedContract marketMaker,
    String marketAddress,
    int outcomeIndex,
    BigInt amount,
  ) async {
    final calcNetCostFunction = marketMaker.function('calcNetCost');

    // Build outcome amounts array [0, 0, amount] for outcomeIndex
    final outcomeAmounts = List<BigInt>.filled(3, BigInt.zero);
    outcomeAmounts[outcomeIndex] = amount;

    final result = await web3Client.call(
      contract: marketMaker,
      function: calcNetCostFunction,
      params: [EthereumAddress.fromHex(marketAddress), outcomeAmounts],
    );

    return (result.first as BigInt).abs(); // Return absolute value
  }

  /// Get token allowance
  Future<BigInt> _getAllowance(
    DeployedContract token,
    EthereumAddress owner,
    EthereumAddress spender,
  ) async {
    final allowanceFunction = token.function('allowance');
    final result = await web3Client.call(
      contract: token,
      function: allowanceFunction,
      params: [owner, spender],
    );
    return result.first as BigInt;
  }

  /// Approve token spending
  Future<String> _approveToken(
    DeployedContract token,
    EthereumAddress spender,
    BigInt amount,
  ) async {
    final approveFunction = token.function('approve');

    final txHash = await web3Client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: token,
        function: approveFunction,
        parameters: [spender, amount],
        maxGas: 100000, // Set explicit gas limit
      ),
      chainId: int.parse(dotenv.env['CHAIN_ID'] ?? '31337'), // Use env chain ID
    );

    // Wait for confirmation
    await _waitForConfirmation(txHash);
    return txHash;
  }

  /// Execute buy transaction
  Future<String> _executeBuy(
    DeployedContract market,
    int outcomeIndex,
    BigInt amount,
    BigInt maxCost, {
    Function(String)? onStatusUpdate,
  }) async {
    final buyFunction = market.function('buy');

    final txHash = await web3Client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: market,
        function: buyFunction,
        parameters: [BigInt.from(outcomeIndex), amount, maxCost],
        maxGas: 500000, // Set explicit gas limit for buy
      ),
      chainId: int.parse(dotenv.env['CHAIN_ID'] ?? '31337'), // Use env chain ID
    );

    // Wait for confirmation
    onStatusUpdate?.call('Confirming transaction...');
    await _waitForConfirmation(txHash);
    return txHash;
  }

  /// Wait for transaction confirmation
  Future<void> _waitForConfirmation(String txHash) async {
    int attempts = 0;
    const maxAttempts = 60; // 2 minutes max (2 sec intervals)

    while (attempts < maxAttempts) {
      try {
        final receipt = await web3Client.getTransactionReceipt(txHash);
        if (receipt != null) {
          if (receipt.status == null || !receipt.status!) {
            throw Exception('Transaction failed');
          }
          debugPrint('Transaction confirmed: $txHash');
          return;
        }
      } catch (e) {
        debugPrint('Waiting for confirmation... attempt $attempts');
      }

      await Future.delayed(const Duration(seconds: 2));
      attempts++;
    }

    throw Exception('Transaction confirmation timeout');
  }
}
