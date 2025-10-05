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
    super.dispose();
  }

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

            // Start/stop timer for live events
            if (eventData['event_status'] == 'live') {
              _startTimer();
            } else {
              _stopTimer();
            }

            final homeTeam =
                (eventData['home_team'] as List?)?.first?['team_name'] ??
                'Home Team';
            final awayTeam =
                (eventData['away_team'] as List?)?.first?['team_name'] ??
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
                    padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Card (Your Progress style)
                        Container(
                          padding: const EdgeInsets.all(20),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Match Progress',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      eventStatus ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isLive
                                            ? '$homeScore - $awayScore'
                                            : 'VS',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Round ${eventData['event_round'] ?? 'N/A'}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (matchProgress != null)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$matchProgress'",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Three boxes layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left tall box
                            Expanded(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Data Box 1',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right two boxes stacked
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 94,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Data Box 2',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 94,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Data Box 3',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bottom card (Breakfast style)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFA6A6), Color(0xFFFF9999)],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Breakfast',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '350 calories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildNutrientColumn('62.5', 'Carbs'),
                                  _buildNutrientColumn('23.6', 'Protein'),
                                  _buildNutrientColumn('45.7', 'Fat'),
                                  _buildNutrientColumn('14%', 'RDC'),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildNutrientColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
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
