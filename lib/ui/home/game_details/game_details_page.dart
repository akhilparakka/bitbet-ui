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
  double _sliderPosition = 0.0;
  bool _isSliding = false;
  Timer? _timer;
  bool _hasInvalidated = false;

  // Bet amount input
  final TextEditingController _betAmountController = TextEditingController();
  String _selectedBetType = 'home'; // 'home', 'draw', 'away'
  double _potentialWinnings = 0.0;

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
    double odds = 0.0;

    if (_selectedBetType == 'home') {
      odds = double.tryParse(homeOdds) ?? 0.0;
    } else if (_selectedBetType == 'draw') {
      odds = double.tryParse(drawOdds) ?? 0.0;
    } else if (_selectedBetType == 'away') {
      odds = double.tryParse(awayOdds) ?? 0.0;
    }

    setState(() {
      _potentialWinnings = betAmount * odds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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

                    if (name == 'Draw') {
                      drawOdds = price?.toString() ?? 'N/A';
                    } else if (name != null && homeTeam.contains(name)) {
                      homeOdds = price?.toString() ?? 'N/A';
                    } else if (name != null && awayTeam.contains(name)) {
                      awayOdds = price?.toString() ?? 'N/A';
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
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFB8A4F5), Color(0xFFA89FF5)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Place Your Bet',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Bet Selection Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildBetOption(
                                        homeTeam,
                                        homeOdds,
                                        'home',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildBetOption(
                                        'Draw',
                                        drawOdds,
                                        'draw',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildBetOption(
                                        awayTeam,
                                        awayOdds,
                                        'away',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Bet Amount Input
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bet Amount',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _betAmountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '0.00',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                          border: InputBorder.none,
                                          prefixText: '\$ ',
                                          prefixStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _calculateWinnings(
                                            value,
                                            homeOdds,
                                            drawOdds,
                                            awayOdds,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Arrow Down Icon
                                Center(
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Potential Winnings Display
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF00BCD4),
                                        Color(0xFF00ACC1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Potential Winnings',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$ ${_potentialWinnings.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                // Bottom Slider Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxSlide = constraints.maxWidth - 120;
                        return Stack(
                          children: [
                            // Background track with arrows and text
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 120),
                                    // Arrow indicators
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Text
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: Text(
                                        'Place Bet',
                                        style: TextStyle(
                                          color:
                                              _sliderPosition > maxSlide * 0.7
                                              ? Colors.transparent
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: _isSliding
                                  ? Duration.zero
                                  : const Duration(milliseconds: 300),
                              left: 4 + _sliderPosition,
                              top: 4,
                              child: GestureDetector(
                                onPanStart: (_) {
                                  setState(() {
                                    _isSliding = true;
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    _sliderPosition =
                                        (_sliderPosition + details.delta.dx)
                                            .clamp(0.0, maxSlide);
                                  });
                                },
                                onPanEnd: (details) {
                                  setState(() {
                                    _isSliding = false;
                                    if (_sliderPosition > maxSlide * 0.8) {
                                      _completeSlide();
                                    } else {
                                      _sliderPosition = 0.0;
                                    }
                                  });
                                },
                                child: Container(
                                  height: 52,
                                  width: 112,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4),
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Bet now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
      setState(() {
        _sliderPosition = 0.0;
      });
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
          _sliderPosition = 0.0;
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
}
