import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction_preview.dart';

class BettingService {
  // USDT always has 6 decimals - hardcoded for performance
  static const int USDT_DECIMALS = 6;

  // ABI cache - loaded once at app start for performance
  static final Map<String, String> _abiCache = {};
  static bool _abisLoaded = false;

  final Web3Client web3Client;
  final EthPrivateKey credentials;

  BettingService({required this.web3Client, required this.credentials});

  /// Initialize ABIs once at app startup (call from main.dart)
  static Future<void> initializeAbis() async {
    if (_abisLoaded) return;

    debugPrint('🔧 Loading contract ABIs...');
    _abiCache['StandardMarket'] = await rootBundle.loadString(
      'assets/frontend_abis/StandardMarket.abi.json',
    );
    _abiCache['ERC20'] = await rootBundle.loadString(
      'assets/frontend_abis/ERC20.abi.json',
    );
    _abiCache['LMSRMarketMaker'] = await rootBundle.loadString(
      'assets/frontend_abis/LMSRMarketMaker.abi.json',
    );
    _abisLoaded = true;
    debugPrint('✅ ABIs loaded and cached');
  }

  /// Get cached ABI (fast synchronous access)
  String _getAbi(String name) {
    if (!_abisLoaded) {
      throw Exception(
        'ABIs not initialized. Call BettingService.initializeAbis() first.',
      );
    }
    final abi = _abiCache[name];
    if (abi == null) {
      throw Exception('ABI not found in cache: $name');
    }
    return abi;
  }

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
      // Get cached ABIs (instant - no I/O)
      // final marketAbi = _getAbi('StandardMarket');
      // final collateralAbi = _getAbi('ERC20');
      final marketMakerAbi = _getAbi('LMSRMarketMaker');

      // Create contract instances
      // final marketContract = DeployedContract(
      //   ContractAbi.fromJson(marketAbi, 'StandardMarket'),
      //   EthereumAddress.fromHex(marketAddress),
      // );

      // final collateralToken = DeployedContract(
      //   ContractAbi.fromJson(collateralAbi, 'ERC20'),
      //   EthereumAddress.fromHex(collateralTokenAddress),
      // );

      final marketMaker = DeployedContract(
        ContractAbi.fromJson(marketMakerAbi, 'LMSRMarketMaker'),
        EthereumAddress.fromHex(marketMakerAddress),
      );

      final betAmount = double.parse(betAmountUSDC);

      // Calculate shares from bet amount and share price
      // User wants to spend betAmount USDT, calculate how many shares they get
      final shares = betAmount / sharePrice;
      final sharesWei = BigInt.from(shares * pow(10, USDT_DECIMALS));

      // Get price quote for the calculated shares
      final estimatedCost = await _getQuote(
        marketMaker,
        marketAddress,
        outcomeIndex,
        sharesWei, // Pass SHARES not betAmount
      );

      final maxCost = (estimatedCost * BigInt.from(105)) ~/ BigInt.from(100);

      // Calculate potential payout and profit
      final estimatedCostDecimal =
          estimatedCost.toDouble() / pow(10, USDT_DECIMALS);
      final maxCostDecimal = maxCost.toDouble() / pow(10, USDT_DECIMALS);
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
        decimals: USDT_DECIMALS,
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
      onStatusUpdate?.call('Loading contracts...');
      debugPrint('=== BETTING DEBUG ===');
      debugPrint('Event ID: $eventId');
      debugPrint('Outcome Index: $outcomeIndex');
      debugPrint('Bet Amount: $betAmountUSDC USDC');
      debugPrint('Market Address: $marketAddress');
      debugPrint('Collateral Address: $collateralTokenAddress');
      debugPrint('Market Maker Address: $marketMakerAddress');

      // Get cached ABIs (instant - no I/O)
      debugPrint('Loading ABIs from cache...');
      final marketAbi = _getAbi('StandardMarket');
      final collateralAbi = _getAbi('ERC20');
      final marketMakerAbi = _getAbi('LMSRMarketMaker');
      debugPrint('ABIs loaded from cache (instant)');

      debugPrint('Creating contract instances...');
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
      debugPrint('Contract instances created');

      // Use hardcoded USDT decimals (no RPC call needed)
      debugPrint('Using USDT decimals: $USDT_DECIMALS (hardcoded)');

      final betAmount = double.parse(betAmountUSDC);
      debugPrint('User wants to spend: $betAmount USDC');
      debugPrint('Current share price: $sharePrice');

      // Calculate how many shares the user can buy
      final shares = betAmount / sharePrice;
      debugPrint('Calculated shares: $shares');
      final sharesWei = BigInt.from(shares * pow(10, USDT_DECIMALS));
      debugPrint('Shares in wei: $sharesWei');

      onStatusUpdate?.call('Checking price and balance...');
      debugPrint('Getting user address...');
      final userAddress = await credentials.extractAddress();
      debugPrint('User address: ${userAddress.hex}');

      // PARALLEL RPC CALLS - Execute all 3 simultaneously for speed
      debugPrint(
        'Fetching balance, allowance, and on-chain quote in parallel...',
      );
      final results = await Future.wait([
        _getBalance(collateralToken, userAddress),
        _getAllowance(
          collateralToken,
          userAddress,
          EthereumAddress.fromHex(marketAddress),
        ),
        _getQuote(marketMaker, marketAddress, outcomeIndex, sharesWei),
      ]);

      final balance = results[0];
      final currentAllowance = results[1];
      final estimatedCost = results[2];

      debugPrint(
        'User balance: ${balance / BigInt.from(pow(10, USDT_DECIMALS))} USDT',
      );
      debugPrint(
        'Current allowance: ${currentAllowance / BigInt.from(pow(10, USDT_DECIMALS))} USDT',
      );
      debugPrint(
        'On-chain quote: ${estimatedCost / BigInt.from(pow(10, USDT_DECIMALS))} USDT',
      );

      // Calculate maxCost with 5% slippage buffer
      final maxCost = (estimatedCost * BigInt.from(105)) ~/ BigInt.from(100);
      debugPrint(
        'Max cost (with slippage): ${maxCost / BigInt.from(pow(10, USDT_DECIMALS))} USDT',
      );

      // Check if balance covers the cost
      if (balance < maxCost) {
        throw Exception(
          'Insufficient balance. You have ${balance / BigInt.from(pow(10, USDT_DECIMALS))} USDT, need ${maxCost / BigInt.from(pow(10, USDT_DECIMALS))} USDT',
        );
      }

      // Approve collateral token (if needed)
      if (currentAllowance < maxCost) {
        onStatusUpdate?.call('Approving USDC...');
        debugPrint('Approving USDC...');
        await _approveToken(
          collateralToken,
          EthereumAddress.fromHex(marketAddress),
          maxCost, // Approve maxCost amount
        );
        debugPrint('Approval confirmed!');
      } else {
        debugPrint('Sufficient allowance already exists, skipping approval');
      }

      // Place the bet
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

  /// Wait for transaction confirmation with exponential backoff
  Future<void> _waitForConfirmation(String txHash) async {
    int attempts = 0;
    const maxAttempts = 30; // Reduced from 60

    // Start at 500ms, double each time up to 3s max
    const initialDelayMs = 500;
    const maxDelayMs = 3000;

    debugPrint('⏳ Waiting for transaction confirmation: $txHash');

    while (attempts < maxAttempts) {
      try {
        final receipt = await web3Client.getTransactionReceipt(txHash);
        if (receipt != null) {
          if (receipt.status == null || !receipt.status!) {
            throw Exception('Transaction failed on-chain');
          }
          debugPrint('✅ Transaction confirmed in ${attempts + 1} attempts');
          return;
        }
      } catch (e) {
        if (e.toString().contains('failed')) rethrow;
        // Ignore receipt not found errors, continue polling
      }

      // Exponential backoff: 500ms → 1s → 2s → 3s → 3s...
      final delayMs = (initialDelayMs * pow(2, attempts)).toInt().clamp(
        0,
        maxDelayMs,
      );
      debugPrint(
        '⏳ Attempt ${attempts + 1}: waiting ${delayMs}ms before next check',
      );
      await Future.delayed(Duration(milliseconds: delayMs));
      attempts++;
    }

    throw Exception(
      'Transaction confirmation timeout after ${maxAttempts * maxDelayMs ~/ 1000}s',
    );
  }
}
