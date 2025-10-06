import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/event_provider.dart';
import 'team_form_page.dart';

class GameDetailsPage extends ConsumerStatefulWidget {
  final String eventId;

  const GameDetailsPage({super.key, required this.eventId});

  @override
  ConsumerState<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends ConsumerState<GameDetailsPage> {
  Timer? _timer;
  bool _hasInvalidated = false;

  // Bet amount input
  final TextEditingController _betAmountController = TextEditingController();
  String _selectedBetType = 'home'; // 'home', 'draw', 'away'
  double _potentialWinnings = 0.0;
  String _selectedTab = 'buy'; // 'buy' or 'sell'
  double _userBalance = 0.00; // Mock balance

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInvalidated) {
      ref.invalidate(eventDetailsProvider(widget.eventId));
      _hasInvalidated = true;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _betAmountController.dispose();
    super.dispose();
  }

  void _calculateWinnings(
    String amount,
    String homeOdds,
    String drawOdds,
    String awayOdds,
  ) {
    final betAmount = double.tryParse(amount) ?? 0.0;
    double cents = 0.0;

    if (_selectedBetType == 'home') {
      cents = double.tryParse(homeOdds) ?? 0.0;
    } else if (_selectedBetType == 'draw') {
      cents = double.tryParse(drawOdds) ?? 0.0;
    } else if (_selectedBetType == 'away') {
      cents = double.tryParse(awayOdds) ?? 0.0;
    }

    setState(() {
      _potentialWinnings = cents > 0 ? betAmount / (cents / 100.0) : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

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
              _startTimer();
            } else {
              _stopTimer();
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
            final isLive =
                eventData['event_status'] != null &&
                eventData['event_status'] != 'Not Started' &&
                eventData['completed'] == false;
            final homeScore = eventData['home_score'];
            final awayScore = eventData['away_score'];
            final matchProgress = eventData['match_progress'];
            final eventStatus = eventData['event_status'] as String?;

            // Extract odds from bookmaker data
            String homeOdds = 'N/A';
            String drawOdds = 'N/A';
            String awayOdds = 'N/A';

            final bookmakers = eventData['has_bookmaker'] as List?;
            if (bookmakers != null && bookmakers.isNotEmpty) {
              final markets = bookmakers[0]['has_market'] as List?;
              if (markets != null && markets.isNotEmpty) {
                final outcomes = markets[0]['has_outcome'] as List?;
                if (outcomes != null) {
                  for (var outcome in outcomes) {
                    final name = outcome['outcome_name'] as String?;
                    final price = outcome['outcome_price'];

                    if (price is int) {
                      final cents = (price / 100).floor();
                      final centsStr = cents.toString();

                      if (name == 'Draw') {
                        drawOdds = centsStr;
                      } else if (name != null && homeTeam.contains(name)) {
                        homeOdds = centsStr;
                      } else if (name != null && awayTeam.contains(name)) {
                        awayOdds = centsStr;
                      }
                    }
                  }
                }
              }
            }

            debugPrint('=== EVENT STATUS: $eventStatus ===');
            debugPrint('=== HOME SCORE: $homeScore ===');
            debugPrint('=== AWAY SCORE: $awayScore ===');
            debugPrint('=== MATCH PROGRESS: $matchProgress ===');
            debugPrint(
              '=== IS NOT STARTED: ${eventStatus == 'Not Started' || eventStatus == null} ===',
            );

            return Column(
              children: [
                // Fixed Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    top: 40.0,
                    right: 20.0,
                    bottom: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black87,
                            size: 18,
                          ),
                        ),
                      ),
                      Text(
                        leagueName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Card (Your Progress style)
                          Container(
                            padding: const EdgeInsets.all(16),
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
                                            : eventStatus ?? 'N/A',
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
                          const SizedBox(height: 16),
                          // Betting Interface Card
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
                                        borderRadius: BorderRadius.circular(8),
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
                                        _selectedBetType == 'home'
                                            ? homeTeam
                                                  .substring(0, 3)
                                                  .toUpperCase()
                                            : _selectedBetType == 'away'
                                            ? awayTeam
                                                  .substring(0, 3)
                                                  .toUpperCase()
                                            : 'DRW',
                                        _selectedBetType == 'home'
                                            ? homeOdds
                                            : _selectedBetType == 'away'
                                            ? awayOdds
                                            : drawOdds,
                                        true,
                                        homeTeam,
                                        awayTeam,
                                        homeOdds,
                                        drawOdds,
                                        awayOdds,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTeamOption(
                                        _selectedBetType == 'away'
                                            ? awayTeam
                                                  .substring(0, 3)
                                                  .toUpperCase()
                                            : _selectedBetType == 'home'
                                            ? homeTeam
                                                  .substring(0, 3)
                                                  .toUpperCase()
                                            : 'DRW',
                                        _selectedBetType == 'away'
                                            ? awayOdds
                                            : _selectedBetType == 'home'
                                            ? homeOdds
                                            : drawOdds,
                                        false,
                                        homeTeam,
                                        awayTeam,
                                        homeOdds,
                                        drawOdds,
                                        awayOdds,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Amount Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: Colors.white.withValues(alpha: 0.5),
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
                                      homeOdds,
                                      drawOdds,
                                      awayOdds,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildQuickAmountButton(
                                      '+\$20',
                                      20,
                                      homeOdds,
                                      drawOdds,
                                      awayOdds,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildQuickAmountButton(
                                      '+\$100',
                                      100,
                                      homeOdds,
                                      drawOdds,
                                      awayOdds,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildQuickAmountButton(
                                      'Max',
                                      _userBalance,
                                      homeOdds,
                                      drawOdds,
                                      awayOdds,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // To Win Section (Animated)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
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
                                              '\$${_potentialWinnings.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFF10B981),
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Avg. Price ${_selectedBetType == 'home'
                                                      ? homeOdds
                                                      : _selectedBetType == 'away'
                                                      ? awayOdds
                                                      : drawOdds}¢',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.6),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.info_outline,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.6),
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                ),
                                // Unavailable Button or Place Bet Button
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _betAmountController.text.isEmpty
                                        ? const Color(0xFF2A3544)
                                        : const Color(0xFF0066CC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_betAmountController.text.isEmpty)
                                        Icon(
                                          Icons.block,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          size: 18,
                                        ),
                                      if (_betAmountController.text.isEmpty)
                                        const SizedBox(width: 8),
                                      Text(
                                        _betAmountController.text.isEmpty
                                            ? 'Unavailable'
                                            : 'Place Bet',
                                        style: TextStyle(
                                          color:
                                              _betAmountController.text.isEmpty
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
                              ],
                            ),
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

  Widget _buildBetOption(String label, String odds, String betType) {
    final isSelected = _selectedBetType == betType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBetType = betType;
          // Recalculate winnings with new selection
          if (_betAmountController.text.isNotEmpty) {
            _calculateWinnings(
              _betAmountController.text,
              betType == 'home' ? odds : '0',
              betType == 'draw' ? odds : '0',
              betType == 'away' ? odds : '0',
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              odds,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String teamName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (logoUrl != null && logoUrl.isNotEmpty)
            Image.network(
              logoUrl,
              height: 80,
              width: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.sports_soccer,
                  size: 60,
                  color: Colors.blue.shade300,
                );
              },
            )
          else
            Icon(Icons.sports_soccer, size: 60, color: Colors.blue.shade300),
          const SizedBox(height: 8),
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _completeSlide() {
    // Validate bet amount
    final betAmount = double.tryParse(_betAmountController.text) ?? 0.0;

    if (betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid bet amount'),
          backgroundColor: Colors.red.shade400,
        ),
      );

      return;
    }

    // Show success message with bet details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bet placed! \$${betAmount.toStringAsFixed(2)} to win \$${_potentialWinnings.toStringAsFixed(2)}',
        ),
        backgroundColor: const Color(0xFF00BCD4),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _betAmountController.clear();
          _potentialWinnings = 0.0;
        });
      }
    });
  }

  Widget _buildInfoBox(String title, Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTeamFormPreview(Map<String, dynamic> eventData) {
    final homeForm = eventData['home_team']?.first?['form_last_5'] ?? 'N/A';
    final awayForm = eventData['away_team']?.first?['form_last_5'] ?? 'N/A';
    return Column(
      children: [
        Text(
          'Home: $homeForm',
          style: const TextStyle(color: Color(0xFF757575)),
        ),
        Text(
          'Away: $awayForm',
          style: const TextStyle(color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Widget _buildLineupsPreview(Map<String, dynamic> eventData) {
    return const Text(
      'Lineups not available',
      style: TextStyle(color: Color(0xFF757575)),
    );
  }

  void _showTeamFormModal(Map<String, dynamic> eventData) {
    final homeTeam =
        (eventData['home_team'] as List?)?.first?['team_name'] ?? 'Home Team';
    final awayTeam =
        (eventData['away_team'] as List?)?.first?['team_name'] ?? 'Away Team';

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TeamFormPage(
          eventId: widget.eventId,
          eventName: eventData['event_name'] ?? 'Event Details',
          homeTeamName: homeTeam,
          awayTeamName: awayTeam,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _showLineupsModal(Map<String, dynamic> eventData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lineups'),
        content: const Text('Lineups not available yet'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _stopTimer(); // Ensure no duplicate timers
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.invalidate(eventDetailsProvider(widget.eventId));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Widget _buildTeamOption(
    String teamAbbr,
    String odds,
    bool isSelected,
    String homeTeam,
    String awayTeam,
    String homeOdds,
    String drawOdds,
    String awayOdds,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle between home and away
          if (_selectedBetType == 'home') {
            _selectedBetType = 'away';
          } else {
            _selectedBetType = 'home';
          }
          // Recalculate winnings with new selection
          if (_betAmountController.text.isNotEmpty) {
            _calculateWinnings(
              _betAmountController.text,
              homeOdds,
              drawOdds,
              awayOdds,
            );
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
              '$odds¢',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
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
    String homeOdds,
    String drawOdds,
    String awayOdds,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            final currentAmount =
                double.tryParse(_betAmountController.text) ?? 0.0;
            final newAmount = label == 'Max' ? amount : currentAmount + amount;
            _betAmountController.text = newAmount.toStringAsFixed(0);
            _calculateWinnings(
              _betAmountController.text,
              homeOdds,
              drawOdds,
              awayOdds,
            );
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
