import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/event_provider.dart';

class GameDetailsPage extends ConsumerStatefulWidget {
  final String eventId;

  const GameDetailsPage({super.key, required this.eventId});

  @override
  ConsumerState<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends ConsumerState<GameDetailsPage> {
  double _sliderPosition = 0.0;
  bool _isSliding = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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

             final homeTeam = (eventData['home_team'] as List?)?.first?['team_name'] ?? 'Home Team';
             final awayTeam = (eventData['away_team'] as List?)?.first?['team_name'] ?? 'Away Team';
             final homeTeamLogo = eventData['home_team_logo'] as String?;
             final awayTeamLogo = eventData['away_team_logo'] as String?;
             final leagueInfo = (eventData['~has_event'] as List?)?.first;
             final sportInfo = (leagueInfo?['~has_league'] as List?)?.first;
             final leagueName = sportInfo?['sport_title'] ?? 'Match Details';

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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Match Title
                        Text(
                          '$homeTeam vs $awayTeam',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Team Logos Container
                        Container(
                          height: 240,
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Home Team Logo
                              Expanded(
                                child: _buildTeamLogo(homeTeamLogo, homeTeam),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Away Team Logo
                              Expanded(
                                child: _buildTeamLogo(awayTeamLogo, awayTeam),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Pagination dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Odds Section
                        const Text(
                          'Odds',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Odds List
                        _buildBookmakersList(eventData),
                        const SizedBox(height: 30),
                      ],
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

  Widget _buildBookmakersList(Map<String, dynamic> eventData) {
    final bookmakers = eventData['has_bookmaker'] as List?;

    if (bookmakers == null || bookmakers.isEmpty) {
      return const Text('No bookmakers available');
    }

    // Show only the first bookmaker
    final firstBookmaker = bookmakers.first;

    return Column(
      children: [firstBookmaker].map((bookmaker) {
        final title = bookmaker['bookmaker_title'] ?? 'Unknown';
        final markets = bookmaker['has_market'] as List?;

        if (markets == null || markets.isEmpty) return const SizedBox.shrink();

        final market = markets.first;
        final outcomes = market['has_outcome'] as List?;

        if (outcomes == null || outcomes.isEmpty)
          return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: outcomes.map<Widget>((outcome) {
              final name = outcome['outcome_name'] ?? '';
              final price = outcome['outcome_price']?.toString() ?? 'N/A';
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  void _completeSlide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bet placed! 🎯'),
        backgroundColor: Color(0xFF00BCD4),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _sliderPosition = 0.0;
        });
      }
    });
  }
}
