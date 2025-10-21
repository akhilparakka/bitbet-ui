import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/event_provider.dart';
import '../../../domain/services/web3_client.dart';

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
  final double _userBalance = 0.00;

  // Betting state
  bool _isPlacingBet = false;
  String? _betStatusMessage;
  String? _betErrorMessage;

  @override
  void initState() {
    super.initState();
    _startPricingTimer();
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

    final sharePrice = (outcomeData['share_price'] as num?)?.toDouble() ?? 0.0;
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
      _betStatusMessage = 'Initializing...';
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

      // Get contract addresses from pricing data
      final pricingData = await ref.read(
        eventPricingProvider(widget.eventId).future,
      );

      if (pricingData == null) {
        throw Exception('Failed to load contract addresses');
      }

      final marketAddress = pricingData['market_address'] as String?;
      final collateralAddress =
          pricingData['collateral_token_address'] as String?;
      final marketMakerAddress = pricingData['market_maker_address'] as String?;

      if (marketAddress == null ||
          collateralAddress == null ||
          marketMakerAddress == null) {
        throw Exception('Contract addresses not available for this event');
      }

      // Place the bet
      final txHash = await bettingService.buyOutcome(
        eventId: widget.eventId,
        outcomeIndex: outcomeIndex,
        betAmountUSDC: _betAmountController.text,
        marketAddress: marketAddress,
        collateralTokenAddress: collateralAddress,
        marketMakerAddress: marketMakerAddress,
        onStatusUpdate: (status) {
          setState(() {
            _betStatusMessage = status;
          });
        },
      );

      // Success!
      setState(() {
        _isPlacingBet = false;
        _betStatusMessage = null;
      });

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
    } catch (e) {
      setState(() {
        _isPlacingBet = false;
        _betStatusMessage = null;
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
    final pricingAsync = ref.watch(eventPricingProvider(widget.eventId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: eventAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading event: $error')),
          data: (eventData) {
            if (eventData == null) {
              return const Center(child: Text('Event not found'));
            }

            debugPrint('=== EVENT DATA: $eventData ===');

            // Start/stop timer for live events
            if (eventData['event_status'] == 'live') {
              _startLiveTimer();
            } else {
              _stopLiveTimer();
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
            final contractDeployed = eventData['contract_deployed'] == true;

            debugPrint('=== EVENT STATUS: $eventStatus ===');
            debugPrint('=== HOME SCORE: $homeScore ===');
            debugPrint('=== AWAY SCORE: $awayScore ===');
            debugPrint('=== MATCH PROGRESS: $matchProgress ===');
            debugPrint(
              '=== IS NOT STARTED: ${eventStatus == 'Not Started' || eventStatus == null} ===',
            );

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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2332),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2A3544),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (eventData['event_league'] as List?)
                                                ?.first?['league_name'] ??
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
                                        color:
                                            (eventStatus == 'Not Started' ||
                                                eventStatus == null)
                                            ? Colors.white.withValues(
                                                alpha: 0.3,
                                              )
                                            : ([
                                                '1H',
                                                '2H',
                                                'HT',
                                                'ET',
                                              ].contains(eventStatus))
                                            ? Colors.red
                                            : Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (eventStatus == 'Not Started' ||
                                                eventStatus == null)
                                            ? 'Not Started'
                                            : ([
                                                '1H',
                                                '2H',
                                                'HT',
                                                'ET',
                                              ].contains(eventStatus))
                                            ? 'LIVE'
                                            : eventStatus,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          if (homeTeamLogo != null &&
                                              homeTeamLogo.isNotEmpty)
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Image.network(
                                                homeTeamLogo,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.sports_soccer,
                                                      size: 40,
                                                    ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.sports_soccer,
                                                size: 40,
                                              ),
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
                                          (eventStatus == 'Not Started' ||
                                                  eventStatus == null)
                                              ? 'VS'
                                              : '$homeScore - $awayScore',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if ([
                                              '1H',
                                              '2H',
                                              'HT',
                                              'ET',
                                            ].contains(eventStatus) &&
                                            matchProgress != null)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                          if (awayTeamLogo != null &&
                                              awayTeamLogo.isNotEmpty)
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Image.network(
                                                awayTeamLogo,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.sports_soccer,
                                                      size: 40,
                                                    ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.sports_soccer,
                                                size: 40,
                                              ),
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
                          ),
                          const SizedBox(height: 24),
                          // Betting Interface Card
                          pricingAsync.when(
                            loading: () => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2332),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2A3544),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, stack) => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2332),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2A3544),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Error loading pricing: $error',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            data: (pricingData) {
                              if (pricingData == null || !contractDeployed) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2332),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF2A3544),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Betting not available',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                );
                              }

                              final homeData =
                                  pricingData['home'] as Map<String, dynamic>?;
                              final drawData =
                                  pricingData['draw'] as Map<String, dynamic>?;
                              final awayData =
                                  pricingData['away'] as Map<String, dynamic>?;

                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2332),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF2A3544),
                                    width: 1,
                                  ),
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
                                                'Buy',
                                                style: TextStyle(
                                                  color: _selectedTab == 'buy'
                                                      ? Colors.white
                                                      : const Color(0xFF6B7280),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (_selectedTab == 'buy')
                                                Container(
                                                  height: 2,
                                                  width: 30,
                                                  color: Colors.white,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
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
                                                'Sell',
                                                style: TextStyle(
                                                  color: _selectedTab == 'sell'
                                                      ? Colors.white
                                                      : const Color(0xFF6B7280),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (_selectedTab == 'sell')
                                                Container(
                                                  height: 2,
                                                  width: 30,
                                                  color: Colors.white,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Market Dropdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A3544),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                'Market',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Team Selection Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTeamOption(
                                            homeTeam
                                                .substring(0, 3)
                                                .toUpperCase(),
                                            'home',
                                            homeData!,
                                            pricingData,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildTeamOption(
                                            'DRW',
                                            'draw',
                                            drawData!,
                                            pricingData,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildTeamOption(
                                            awayTeam
                                                .substring(0, 3)
                                                .toUpperCase(),
                                            'away',
                                            awayData!,
                                            pricingData,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Amount Section
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Amount',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
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
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Quick Amount Buttons
                                    Row(
                                      children: [
                                        _buildQuickAmountButton(
                                          '+\$1',
                                          1,
                                          pricingData,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildQuickAmountButton(
                                          '+\$20',
                                          20,
                                          pricingData,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildQuickAmountButton(
                                          '+\$100',
                                          100,
                                          pricingData,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildQuickAmountButton(
                                          'Max',
                                          _userBalance,
                                          pricingData,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // To Win Section (Animated)
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: _betAmountController.text.isEmpty
                                          ? Container()
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'To win ',
                                                      style: TextStyle(
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
                                                Text(
                                                  '\$${_grossWinnings.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF10B981),
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // const SizedBox(height: 4),
                                                // Text(
                                                //   'You\'ll get ${_shares.toStringAsFixed(2)} shares @ \$${_sharePrice.toStringAsFixed(2)}',
                                                //   style: TextStyle(
                                                //     color: Colors.white
                                                //         .withValues(alpha: 0.6),
                                                //     fontSize: 12,
                                                //   ),
                                                // ),
                                                // const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Profit: ',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      '+\$${_netProfit.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      ' (${(_netProfit / (double.tryParse(_betAmountController.text) ?? 1) * 100).toStringAsFixed(1)}%)',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                    ),
                                    // Place Bet Button
                                    GestureDetector(
                                      onTap:
                                          _betAmountController.text.isEmpty ||
                                              _isPlacingBet
                                          ? null
                                          : _placeBet,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _betAmountController
                                                      .text
                                                      .isEmpty ||
                                                  _isPlacingBet
                                              ? const Color(0xFF2A3544)
                                              : const Color(0xFF0066CC),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_isPlacingBet)
                                              const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              ),
                                            if (_isPlacingBet)
                                              const SizedBox(width: 8),
                                            if (!_isPlacingBet &&
                                                _betAmountController
                                                    .text
                                                    .isEmpty)
                                              Icon(
                                                Icons.block,
                                                color: Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                                size: 18,
                                              ),
                                            if (!_isPlacingBet &&
                                                _betAmountController
                                                    .text
                                                    .isEmpty)
                                              const SizedBox(width: 8),
                                            Text(
                                              _isPlacingBet
                                                  ? _betStatusMessage ??
                                                        'Processing...'
                                                  : _betAmountController
                                                        .text
                                                        .isEmpty
                                                  ? 'Unavailable'
                                                  : 'Place Bet',
                                              style: TextStyle(
                                                color:
                                                    _betAmountController
                                                            .text
                                                            .isEmpty ||
                                                        _isPlacingBet
                                                    ? Colors.white.withValues(
                                                        alpha: 0.5,
                                                      )
                                                    : Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamOption(
    String teamAbbr,
    String betType,
    Map<String, dynamic> outcomeData,
    Map<String, dynamic> pricingData,
  ) {
    final isSelected = _selectedBetType == betType;
    final multiplier = (outcomeData['multiplier'] as num?)?.toDouble() ?? 0.0;
    final probability = (outcomeData['probability'] as num?)?.toDouble() ?? 0.0;

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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066CC) : const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
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
    Map<String, dynamic> pricingData,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            final currentAmount =
                double.tryParse(_betAmountController.text) ?? 0.0;
            final newAmount = label == 'Max' ? amount : currentAmount + amount;
            _betAmountController.text = newAmount.toStringAsFixed(0);
            _calculateWinnings(_betAmountController.text, pricingData);
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
}
