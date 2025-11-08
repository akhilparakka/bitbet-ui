import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/providers/event_provider.dart';
import '../../../domain/providers/user_bets_provider.dart';
import '../../../domain/providers/user_provider.dart';
import '../../../domain/services/web3_client.dart';
import '../../../domain/models/transaction_preview.dart';
import '../../custom_widgets/shimmer_widget.dart';
import 'transaction_preview_sheet.dart';
import 'sell_transaction_preview_sheet.dart';

class GameDetailsPage extends ConsumerStatefulWidget {
  final String eventId;

  const GameDetailsPage({super.key, required this.eventId});

  @override
  ConsumerState<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends ConsumerState<GameDetailsPage> {
  Timer? _pricingTimer;
  Timer? _liveTimer;
  bool _hasInvalidated = false;

  final TextEditingController _betAmountController = TextEditingController();
  String _selectedBetType = 'home'; // 'home', 'draw', 'away'
  double _grossWinnings = 0.0;
  double _netProfit = 0.0;
  double _shares = 0.0;
  double _sharePrice = 0.0;
  String _selectedTab = 'buy'; // 'buy' or 'sell'
  bool _isBasicMode = true; // Basic or Advanced mode
  double _userBalance = 0.00;

  // Sell state
  String _selectedSellOutcome = 'home'; // 'home', 'draw', 'away'
  double _sellAmount = 0.0;
  double _sellWinnings = 0.0;

  // Betting state
  bool _isPlacingBet = false;
  bool _isButtonPressed = false;
  String? _betErrorMessage;

  @override
  void initState() {
    super.initState();
    _startPricingTimer();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    try {
      final web3Client = Web3BetClient();
      final usdtAddress = dotenv.env['USDT_CONTRACT_ADDRESS'];
      if (usdtAddress != null && usdtAddress.isNotEmpty) {
        final balance = await web3Client.getUsdtBalance(usdtAddress);
        if (mounted) {
          setState(() {
            _userBalance = balance;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading USDT balance: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInvalidated) {
      ref.invalidate(eventDetailsProvider(widget.eventId));
      ref.invalidate(eventPricingProvider(widget.eventId));
      _hasInvalidated = true;
    }
  }

  @override
  void dispose() {
    _stopPricingTimer();
    _stopLiveTimer();
    _betAmountController.dispose();
    super.dispose();
  }

  Map<String, double> _getHoldingsForMarket(
    List<dynamic>? holdings,
    String eventId,
  ) {
    final Map<String, double> marketHoldings = {
      'home': 0.0,
      'draw': 0.0,
      'away': 0.0,
    };

    if (holdings == null) return marketHoldings;

    for (final holding in holdings) {
      if (holding.eventId == eventId) {
        final outcomeKey = holding.outcomeIndex == 0
            ? 'home'
            : holding.outcomeIndex == 1
            ? 'draw'
            : 'away';
        final shares = double.tryParse(holding.shares) ?? 0.0;
        marketHoldings[outcomeKey] = marketHoldings[outcomeKey]! + shares;
      }
    }

    return marketHoldings;
  }

  void _calculateSellWinnings(
    String amount,
    Map<String, dynamic>? pricingData,
  ) {
    if (pricingData == null) return;

    final sellAmount = double.tryParse(amount) ?? 0.0;
    if (sellAmount <= 0) {
      setState(() {
        _sellWinnings = 0.0;
      });
      return;
    }

    final outcomeData = pricingData[_selectedSellOutcome];
    if (outcomeData == null) return;

    // Handle both string and number types from API
    final sharePriceValue = outcomeData['share_price'];
    final sharePrice = sharePriceValue is num
        ? sharePriceValue.toDouble()
        : (sharePriceValue is String
              ? double.tryParse(sharePriceValue) ?? 0.0
              : 0.0);
    if (sharePrice <= 0) return;

    // For selling, estimate proceeds based on current share price
    // TODO: This should use proper LMSR sell calculation, not just sharePrice * amount
    // For now, this gives a reasonable estimate
    final estimatedProceeds = sellAmount * sharePrice;

    setState(() {
      _sellWinnings = estimatedProceeds;
    });
  }

  void _calculateWinnings(String amount, Map<String, dynamic>? pricingData) {
    if (pricingData == null) return;

    final betAmount = double.tryParse(amount) ?? 0.0;
    if (betAmount <= 0) {
      setState(() {
        _grossWinnings = 0.0;
        _netProfit = 0.0;
        _shares = 0.0;
        _sharePrice = 0.0;
      });
      return;
    }

    final outcomeData = pricingData[_selectedBetType];
    if (outcomeData == null) return;

    // Handle both string and number types from API
    final sharePriceValue = outcomeData['share_price'];
    final sharePrice = sharePriceValue is num
        ? sharePriceValue.toDouble()
        : (sharePriceValue is String
              ? double.tryParse(sharePriceValue) ?? 0.0
              : 0.0);
    if (sharePrice <= 0) return;

    final shares = betAmount / sharePrice;
    final grossWinnings = shares * 1.0;
    final netProfit = grossWinnings - betAmount;

    setState(() {
      _grossWinnings = grossWinnings;
      _netProfit = netProfit;
      _shares = shares;
      _sharePrice = sharePrice;
    });
  }

  void _startPricingTimer() {
    _stopPricingTimer();
    _pricingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(eventPricingProvider(widget.eventId));
    });
  }

  void _stopPricingTimer() {
    _pricingTimer?.cancel();
    _pricingTimer = null;
  }

  void _startLiveTimer() {
    _stopLiveTimer();
    _liveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.invalidate(eventDetailsProvider(widget.eventId));
    });
  }

  void _stopLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  /// Sell tokens for selected outcome
  Future<void> _sellTokens() async {
    // Validate inputs
    if (_sellAmount <= 0) {
      setState(() {
        _betErrorMessage = 'Please enter amount to sell';
      });
      return;
    }

    setState(() {
      _isPlacingBet = true;
      _betErrorMessage = null;
    });

    try {
      // Get betting service
      final bettingService = Web3BetClient().getBettingService();
      if (bettingService == null) {
        throw Exception('Please login first');
      }

      // Get event and pricing data
      final pricingData = await ref.read(
        eventPricingProvider(widget.eventId).future,
      );
      final eventData = await ref.read(
        eventDetailsProvider(widget.eventId).future,
      );

      if (pricingData == null || eventData == null) {
        throw Exception('Failed to load event data');
      }

      // Get contract addresses
      final marketAddress = pricingData['market_address'] as String?;
      final marketMakerAddress = pricingData['market_maker_address'] as String?;
      // For now, try to get event contract from various possible fields
      final eventContractAddress =
          eventData['event_contract_address'] as String? ??
          eventData['contract_address'] as String? ??
          pricingData['event_contract_address'] as String?;

      debugPrint('=== CONTRACT ADDRESSES ===');
      debugPrint('Market Address: $marketAddress');
      debugPrint('Event Contract Address: $eventContractAddress');
      debugPrint('Available event fields: ${eventData.keys.join(', ')}');
      debugPrint('Available pricing fields: ${pricingData.keys.join(', ')}');

      if (marketAddress == null) {
        throw Exception('Market contract address not available');
      }

      if (marketMakerAddress == null) {
        throw Exception('Market maker contract address not available');
      }

      if (eventContractAddress == null) {
        throw Exception(
          'Event contract address not available in API response. Required fields: event_contract_address, contract_address, or pricing.event_contract_address. Available event fields: ${eventData.keys.join(', ')}',
        );
      }

      // Map bet type to outcome index
      final outcomeIndex = _selectedSellOutcome == 'home'
          ? 0
          : _selectedSellOutcome == 'draw'
          ? 1
          : 2;

      // Get bet type display name
      final outcomeDisplay = _selectedSellOutcome == 'home'
          ? 'Home Win'
          : _selectedSellOutcome == 'draw'
          ? 'Draw'
          : 'Away Win';

      // Create transaction preview (simplified for sell)
      final preview = TransactionPreview(
        eventName: eventData['event_name'] ?? 'Unknown Event',
        betType: outcomeDisplay,
        betAmount: _sellAmount, // This is tokens, not USDT
        estimatedCost: 0.0, // Not applicable for sell
        maxCost: 0.0, // Not applicable for sell
        shares: _sellAmount,
        potentialPayout: _sellWinnings,
        netProfit: _sellWinnings, // Simplified
        marketAddress: marketAddress,
        collateralTokenAddress: '', // Not needed for sell
        marketMakerAddress: '', // Not needed for sell
        estimatedGas: 300000,
        gasPrice: 20.0, // Placeholder
        estimatedGasCost: 0.006, // Placeholder
        decimals: 6,
      );

      // Hide loading state for preview
      setState(() {
        _isPlacingBet = false;
      });

      // Show preview bottom sheet
      if (mounted) {
        final shouldProceed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: false,
          builder: (context) => GestureDetector(
            onTap: () => Navigator.pop(context, false),
            behavior: HitTestBehavior.opaque,
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25,
                ),
                child: SellTransactionPreviewSheet(
                  preview: preview,
                  onProceed: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ),
              ),
            ),
          ),
        );

        // If user cancelled, return
        if (shouldProceed != true) {
          return;
        }

        // User confirmed, proceed with transaction
        setState(() {
          _isPlacingBet = true;
        });

        // Execute the actual sell transaction
        final txHash = await bettingService.sellOutcome(
          eventId: widget.eventId,
          outcomeIndex: outcomeIndex,
          tokenCount: _sellAmount.toString(),
          marketAddress: marketAddress,
          marketMakerAddress: marketMakerAddress,
          eventContractAddress: eventContractAddress,
          slippagePercent: 10.0, // Default 10% slippage protection
          onStatusUpdate: (status) {
            setState(() {
              _betErrorMessage = status;
            });
          },
        );

        // Success!
        setState(() {
          _isPlacingBet = false;
        });

        // Invalidate bets data to refresh holdings
        final userId = await ref.read(userIdProvider.future);
        if (userId != null) {
          ref.invalidate(userBetsProvider(userId));
        }

        // Reload balance after successful sell
        _loadUserBalance();

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tokens Sold!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your tokens were sold successfully!'),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction: ${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }

        // Clear sell amount
        setState(() {
          _sellAmount = 0.0;
          _sellWinnings = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _isPlacingBet = false;
        _betErrorMessage = e.toString();
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(_betErrorMessage ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Place a bet on selected outcome
  Future<void> _placeBet() async {
    // Validate inputs
    if (_betAmountController.text.isEmpty) {
      setState(() {
        _betErrorMessage = 'Please enter a bet amount';
      });
      return;
    }

    final betAmount = double.tryParse(_betAmountController.text);
    if (betAmount == null || betAmount <= 0) {
      setState(() {
        _betErrorMessage = 'Invalid bet amount';
      });
      return;
    }

    setState(() {
      _isPlacingBet = true;
      _betErrorMessage = null;
    });

    try {
      // Get betting service
      final bettingService = Web3BetClient().getBettingService();
      if (bettingService == null) {
        throw Exception('Please login first');
      }

      // Map bet type to outcome index
      final outcomeIndex = _selectedBetType == 'home'
          ? 0
          : _selectedBetType == 'draw'
          ? 1
          : 2;

      // Get bet type display name
      final betTypeDisplay = _selectedBetType == 'home'
          ? 'Home Win'
          : _selectedBetType == 'draw'
          ? 'Draw'
          : 'Away Win';

      // Get contract addresses and event data
      final pricingData = await ref.read(
        eventPricingProvider(widget.eventId).future,
      );
      final eventData = await ref.read(
        eventDetailsProvider(widget.eventId).future,
      );

      if (pricingData == null || eventData == null) {
        throw Exception('Failed to load event data');
      }

      final marketAddress = pricingData['market_address'] as String?;
      final collateralAddress =
          pricingData['collateral_token_address'] as String?;
      final marketMakerAddress = pricingData['market_maker_address'] as String?;
      final eventName = eventData['event_name'] as String? ?? 'Unknown Event';

      if (marketAddress == null ||
          collateralAddress == null ||
          marketMakerAddress == null) {
        throw Exception('Contract addresses not available for this event');
      }

      // Get share price from pricing data
      final outcomeData = pricingData[_selectedBetType];

      // Handle both string and number types from API
      final sharePriceValue = outcomeData?['share_price'];
      final sharePrice = sharePriceValue is num
          ? sharePriceValue.toDouble()
          : (sharePriceValue is String
                ? double.tryParse(sharePriceValue) ?? 0.0
                : 0.0);

      if (sharePrice <= 0) {
        throw Exception('Share price not available');
      }

      // Simulate the transaction
      final preview = await bettingService.simulateBet(
        eventName: eventName,
        betType: betTypeDisplay,
        outcomeIndex: outcomeIndex,
        betAmountUSDC: _betAmountController.text,
        sharePrice: sharePrice,
        marketAddress: marketAddress,
        collateralTokenAddress: collateralAddress,
        marketMakerAddress: marketMakerAddress,
      );

      // Hide loading state
      setState(() {
        _isPlacingBet = false;
      });

      // Show preview bottom sheet
      if (mounted) {
        final shouldProceed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: true, // Allow dismissing by tapping outside
          enableDrag: false,
          builder: (context) => GestureDetector(
            onTap: () =>
                Navigator.pop(context, false), // Close on background tap
            behavior: HitTestBehavior.opaque,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from bubbling up from the sheet
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25,
                ),
                child: TransactionPreviewSheet(
                  preview: preview,
                  onProceed: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ),
              ),
            ),
          ),
        );

        // If user cancelled, return
        if (shouldProceed != true) {
          return;
        }

        // User confirmed, proceed with transaction
        setState(() {
          _isPlacingBet = true;
        });

        // Execute the actual transaction
        final txHash = await bettingService.buyOutcome(
          eventId: widget.eventId,
          outcomeIndex: outcomeIndex,
          betAmountUSDC: _betAmountController.text,
          sharePrice: sharePrice,
          marketAddress: marketAddress,
          collateralTokenAddress: collateralAddress,
          marketMakerAddress: marketMakerAddress,
          onStatusUpdate: (status) {
            // Status updates not needed in UI
          },
        );

        // Success!
        setState(() {
          _isPlacingBet = false;
        });

        // Invalidate bets data to refresh My Bets section
        final userId = await ref.read(userIdProvider.future);
        if (userId != null) {
          ref.invalidate(userBetsProvider(userId));
        }

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Bet Placed!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your bet was placed successfully!'),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction: ${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }

        // Clear bet amount
        _betAmountController.clear();
        _calculateWinnings('', null);

        // Reload balance after successful bet
        _loadUserBalance();
      }
    } catch (e) {
      setState(() {
        _isPlacingBet = false;
        _betErrorMessage = e.toString();
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(_betErrorMessage ?? 'Unknown error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    ref.watch(eventPricingProvider(widget.eventId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: _buildContent(eventAsync.value)),
    );
  }

  Widget _buildContent(Map<String, dynamic>? eventData) {
    final pricingAsync = ref.watch(eventPricingProvider(widget.eventId));

    // Handle live timer based on event data
    if (eventData != null) {
      if (eventData['event_status'] == 'live') {
        _startLiveTimer();
      } else {
        _stopLiveTimer();
      }
    }

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Card (Your Progress style)
                  _buildTopCard(eventData),
                  const SizedBox(height: 24),
                  // Betting Interface Card
                  _buildBettingCard(eventData, pricingAsync.value),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCard(Map<String, dynamic>? eventData) {
    if (eventData == null) {
      return _buildTopCardSkeleton();
    }

    final homeTeam =
        (eventData['home_team'] as List?)?.first?['team_name'] ??
        eventData['home_team_name'] ??
        'Home Team';
    final awayTeam =
        (eventData['away_team'] as List?)?.first?['team_name'] ??
        eventData['away_team_name'] ??
        'Away Team';
    final homeTeamLogo = eventData['home_team_logo'] as String?;
    final awayTeamLogo = eventData['away_team_logo'] as String?;
    final leagueName = 'Soccer';
    final homeScore = eventData['home_score'];
    final awayScore = eventData['away_score'];
    final matchProgress = eventData['match_progress'];
    final eventStatus = eventData['event_status'] as String?;

    debugPrint('=== MATCH PROGRESS: $matchProgress ===');
    debugPrint(
      '=== IS NOT STARTED: ${eventStatus == 'Not Started' || eventStatus == null} ===',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (eventData['event_league'] as List?)?.first?['league_name'] ??
                      leagueName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (eventStatus == 'Not Started' || eventStatus == null)
                      ? Colors.white.withValues(alpha: 0.3)
                      : (['1H', '2H', 'HT', 'ET'].contains(eventStatus))
                      ? Colors.red
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (eventStatus == 'Not Started' || eventStatus == null)
                      ? 'Not Started'
                      : (['1H', '2H', 'HT', 'ET'].contains(eventStatus))
                      ? 'LIVE'
                      : eventStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (homeTeamLogo != null && homeTeamLogo.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: CachedNetworkImage(
                          imageUrl: homeTeamLogo,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.sports_soccer, size: 40),
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sports_soccer, size: 40),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      homeTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    (eventStatus == 'Not Started' || eventStatus == null)
                        ? 'VS'
                        : '$homeScore - $awayScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (['1H', '2H', 'HT', 'ET'].contains(eventStatus) &&
                      matchProgress != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$matchProgress'",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    if (awayTeamLogo != null && awayTeamLogo.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: CachedNetworkImage(
                          imageUrl: awayTeamLogo,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.sports_soccer, size: 40),
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sports_soccer, size: 40),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      awayTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Round ${eventData['event_round'] ?? 'N/A'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCardSkeleton() {
    return ShimmerWidget(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A3544), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3544),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3544),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3544),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3544),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3544),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3544),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3544),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 14,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3544),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBettingCard(
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? pricingData,
  ) {
    final contractDeployed = eventData?['contract_deployed'] == true;

    if (!contractDeployed) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A3544), width: 1),
        ),
        child: const Center(
          child: Text(
            'Betting not available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final homeTeam =
        (eventData!['home_team'] as List?)?.first?['team_name'] ??
        eventData['home_team_name'] ??
        'Home';
    final awayTeam =
        (eventData['away_team'] as List?)?.first?['team_name'] ??
        eventData['away_team_name'] ??
        'Away';

    final homeData = pricingData?['home'] as Map<String, dynamic>?;
    final drawData = pricingData?['draw'] as Map<String, dynamic>?;
    final awayData = pricingData?['away'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy/Sell Tabs with Market Dropdown
          Row(
            children: [
              // Buy Tab
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = 'buy';
                  });
                },
                child: Column(
                  children: [
                    Text(
                      _getBuyTabLabel(),
                      style: TextStyle(
                        color: _selectedTab == 'buy'
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_selectedTab == 'buy')
                      Container(height: 2, width: 30, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Sell Tab
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = 'sell';
                  });
                },
                child: Column(
                  children: [
                    Text(
                      _getSellTabLabel(),
                      style: TextStyle(
                        color: _selectedTab == 'sell'
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_selectedTab == 'sell')
                      Container(height: 2, width: 30, color: Colors.white),
                  ],
                ),
              ),
              const Spacer(),
              // Basic/Advanced Mode Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildModeButton('Basic', _isBasicMode),
                    _buildModeButton('Advanced', !_isBasicMode),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Team Selection Buttons or Holdings Display
          if (_selectedTab == 'buy')
            Row(
              children: [
                Expanded(
                  child: _buildTeamOption(
                    homeTeam.substring(0, 3).toUpperCase(),
                    'home',
                    homeData,
                    pricingData,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTeamOption('DRW', 'draw', drawData, pricingData),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTeamOption(
                    awayTeam.substring(0, 3).toUpperCase(),
                    'away',
                    awayData,
                    pricingData,
                  ),
                ),
              ],
            )
          else
            _buildSellHoldingsSection(eventData, pricingData),
          const SizedBox(height: 20),
          // Amount Section
          if (_selectedTab == 'buy') ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _betAmountController.text.isEmpty
                      ? '\$0'
                      : '\$${_betAmountController.text}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Balance \$${_userBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _sellAmount == 0.0
                      ? '0'
                      : _sellAmount < 0.01
                      ? _sellAmount.toStringAsExponential(2)
                      : _sellAmount.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'shares',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Quick Amount Buttons
          if (_selectedTab == 'buy')
            Row(
              children: [
                _buildQuickAmountButton('+\$1', 1, pricingData),
                const SizedBox(width: 8),
                _buildQuickAmountButton('+\$20', 20, pricingData),
                const SizedBox(width: 8),
                _buildQuickAmountButton('+\$100', 100, pricingData),
                const SizedBox(width: 8),
                _buildQuickAmountButton('Max', _userBalance, pricingData),
              ],
            )
          else
            _buildSellQuickAmountButtons(pricingData),
          const SizedBox(height: 16),
          // To Win / You Receive Section (Animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                (_selectedTab == 'buy' && _betAmountController.text.isEmpty) ||
                    (_selectedTab == 'sell' && _sellAmount == 0.0)
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedTab == 'buy' ? 'To win ' : 'You receive ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          () {
                            final amount = _selectedTab == 'buy'
                                ? _grossWinnings
                                : _sellWinnings;
                            return '\$${amount < 0.01 ? amount.toStringAsExponential(2) : amount.toStringAsFixed(2)}';
                          }(),
                          key: ValueKey<double>(
                            _selectedTab == 'buy'
                                ? _grossWinnings
                                : _sellWinnings,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_selectedTab == 'buy')
                        Row(
                          children: [
                            Text(
                              'Profit: ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '+\$${_netProfit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${(_netProfit / (double.tryParse(_betAmountController.text) ?? 1) * 100).toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
          // Place Bet / Sell Tokens Button
          GestureDetector(
            onTap:
                (_selectedTab == 'buy' &&
                        (_betAmountController.text.isEmpty ||
                            _isPlacingBet ||
                            pricingData == null)) ||
                    (_selectedTab == 'sell' &&
                        (_sellAmount == 0.0 ||
                            _isPlacingBet ||
                            pricingData == null))
                ? null
                : (_selectedTab == 'buy' ? _placeBet : _sellTokens),
            onTapDown: (_) => setState(() => _isButtonPressed = true),
            onTapUp: (_) => setState(() => _isButtonPressed = false),
            onTapCancel: () => setState(() => _isButtonPressed = false),
            child: AnimatedScale(
              scale: _isButtonPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color:
                      (_selectedTab == 'buy' &&
                              (_betAmountController.text.isEmpty ||
                                  _isPlacingBet ||
                                  pricingData == null)) ||
                          (_selectedTab == 'sell' &&
                              (_sellAmount == 0.0 ||
                                  _isPlacingBet ||
                                  pricingData == null))
                      ? const Color(0xFF2A3544)
                      : const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isPlacingBet)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    if (_isPlacingBet) const SizedBox(width: 8),
                    if (!_isPlacingBet &&
                        ((_selectedTab == 'buy' &&
                                (_betAmountController.text.isEmpty ||
                                    pricingData == null)) ||
                            (_selectedTab == 'sell' &&
                                (_sellAmount == 0.0 || pricingData == null))))
                      Icon(
                        Icons.block,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    if (!_isPlacingBet &&
                        ((_selectedTab == 'buy' &&
                                (_betAmountController.text.isEmpty ||
                                    pricingData == null)) ||
                            (_selectedTab == 'sell' &&
                                (_sellAmount == 0.0 || pricingData == null))))
                      const SizedBox(width: 8),
                    if (!_isPlacingBet)
                      Text(
                        (_selectedTab == 'buy' &&
                                    (_betAmountController.text.isEmpty ||
                                        pricingData == null)) ||
                                (_selectedTab == 'sell' &&
                                    (_sellAmount == 0.0 || pricingData == null))
                            ? 'Unavailable'
                            : (_selectedTab == 'buy'
                                  ? (_isBasicMode
                                        ? 'Place Bet'
                                        : 'Place Multi Bets')
                                  : (_isBasicMode ? 'Sell Tokens' : 'Short')),
                        style: TextStyle(
                          color:
                              (_selectedTab == 'buy' &&
                                      (_betAmountController.text.isEmpty ||
                                          pricingData == null)) ||
                                  (_selectedTab == 'sell' &&
                                      (_sellAmount == 0.0 ||
                                          pricingData == null))
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOption(
    String teamAbbr,
    String betType,
    Map<String, dynamic>? outcomeData,
    Map<String, dynamic>? pricingData,
  ) {
    final isSelected = _selectedBetType == betType;

    // Handle loading state
    if (outcomeData == null) {
      return ShimmerWidget(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3544),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                height: 18,
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4554),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 17,
                width: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4554),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 14,
                width: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4554),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle both string and number types from API
    final multiplierValue = outcomeData['multiplier'];
    final multiplier = multiplierValue is num
        ? multiplierValue.toDouble()
        : (multiplierValue is String
              ? double.tryParse(multiplierValue) ?? 0.0
              : 0.0);

    final probabilityValue = outcomeData['probability'];
    final probability = probabilityValue is num
        ? probabilityValue.toDouble()
        : (probabilityValue is String
              ? double.tryParse(probabilityValue) ?? 0.0
              : 0.0);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBetType = betType;
          // Recalculate winnings with new selection
          if (_betAmountController.text.isNotEmpty) {
            _calculateWinnings(_betAmountController.text, pricingData);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purple.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              teamAbbr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${multiplier.toStringAsFixed(1)}x',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${probability.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(
    String label,
    double amount,
    Map<String, dynamic>? pricingData,
  ) {
    final buttonContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: pricingData == null
            ? const Color(0xFF2A3544)
            : const Color(0xFF374151),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: pricingData == null
            ? Container(
                height: 15,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4554),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );

    return Expanded(
      child: pricingData == null
          ? ShimmerWidget(child: buttonContent)
          : GestureDetector(
              onTap: () {
                setState(() {
                  final currentAmount =
                      double.tryParse(_betAmountController.text) ?? 0.0;
                  final newAmount = label == 'Max'
                      ? amount
                      : currentAmount + amount;
                  _betAmountController.text = newAmount.toStringAsFixed(0);
                  _calculateWinnings(_betAmountController.text, pricingData);
                });
              },
              child: buttonContent,
            ),
    );
  }

  Widget _buildSellHoldingsSection(
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? pricingData,
  ) {
    final userId = ref.watch(userIdProvider).value;
    if (userId == null) {
      return const Center(
        child: Text(
          'Please login to view holdings',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final userBetsAsync = ref.watch(userBetsProvider(userId));

    // Show skeleton loaders while loading
    if (userBetsAsync.isLoading) {
      return Row(
        children: [
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final holdings = userBetsAsync.value?['holdings'] as List<dynamic>?;

    final eventId = eventData?['id']?.toString() ?? widget.eventId;
    final marketHoldings = _getHoldingsForMarket(holdings, eventId);

    final hasAnyHoldings = marketHoldings.values.any((holding) => holding > 0);

    if (!hasAnyHoldings) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No tokens to sell',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final homeTeam =
        (eventData!['home_team'] as List?)?.first?['team_name'] ??
        eventData['home_team_name'] ??
        'Home';
    final awayTeam =
        (eventData['away_team'] as List?)?.first?['team_name'] ??
        eventData['away_team_name'] ??
        'Away';

    return Column(
      children: [
        Row(
          children: [
            if (marketHoldings['home']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  homeTeam.substring(0, 3).toUpperCase(),
                  'home',
                  marketHoldings['home']!,
                  pricingData,
                ),
              ),
            if (marketHoldings['home']! > 0) const SizedBox(width: 8),
            if (marketHoldings['draw']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  'DRW',
                  'draw',
                  marketHoldings['draw']!,
                  pricingData,
                ),
              ),
            if (marketHoldings['draw']! > 0 && marketHoldings['away']! > 0)
              const SizedBox(width: 8),
            if (marketHoldings['away']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  awayTeam.substring(0, 3).toUpperCase(),
                  'away',
                  marketHoldings['away']!,
                  pricingData,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellQuickAmountButtons(Map<String, dynamic>? pricingData) {
    final userId = ref.watch(userIdProvider).value;
    if (userId == null) return const SizedBox.shrink();

    final userBetsAsync = ref.watch(userBetsProvider(userId));

    // Show skeleton buttons while loading
    if (userBetsAsync.isLoading) {
      return Row(
        children: [
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    height: 15,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4554),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    height: 15,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4554),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    height: 15,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4554),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    height: 15,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4554),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final holdings = userBetsAsync.value?['holdings'] as List<dynamic>?;

    final eventData = ref.watch(eventDetailsProvider(widget.eventId)).value;
    final eventId = eventData?['id']?.toString() ?? widget.eventId;
    final marketHoldings = _getHoldingsForMarket(holdings, eventId);
    final maxAmountTokens = marketHoldings[_selectedSellOutcome] ?? 0.0;
    final maxAmountShares =
        maxAmountTokens /
        1e18; // Convert from wei to human readable (18 decimals)

    return Row(
      children: [
        _buildSellAmountButton('25%', maxAmountShares * 0.25, pricingData),
        const SizedBox(width: 8),
        _buildSellAmountButton('50%', maxAmountShares * 0.5, pricingData),
        const SizedBox(width: 8),
        _buildSellAmountButton('75%', maxAmountShares * 0.75, pricingData),
        const SizedBox(width: 8),
        _buildSellAmountButton('Max', maxAmountShares, pricingData),
      ],
    );
  }

  Widget _buildSellAmountButton(
    String label,
    double amount,
    Map<String, dynamic>? pricingData,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _sellAmount = amount;
            _calculateSellWinnings(amount.toString(), pricingData);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellHoldingOption(
    String teamAbbr,
    String outcome,
    double holdingAmount,
    Map<String, dynamic>? pricingData,
  ) {
    final isSelected = _selectedSellOutcome == outcome;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSellOutcome = outcome;
          // Reset sell amount when changing outcome
          _sellAmount = 0.0;
          _sellWinnings = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purple.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              teamAbbr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (holdingAmount / 1e18).toStringAsFixed(2),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'shares',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBuyTabLabel() {
    return _isBasicMode ? 'Buy' : 'Multi Buy';
  }

  String _getSellTabLabel() {
    return _isBasicMode ? 'Sell' : 'Short';
  }

  Widget _buildModeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isBasicMode = label == 'Basic'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
