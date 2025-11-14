import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../home/game_details/game_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;
  String _query = '';

  // TODO: Replace with actual API data
  Map<String, dynamic>? _searchResults;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _query = '';
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _query = query;
    });

    // Debounce: Wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    debugPrint('🔍 Searching for: $query');

    // TODO: Call API
    // final url = Uri.parse('http://localhost:3000/search?q=$query&limit=5');
    // final response = await http.get(url);
    // final data = jsonDecode(response.body);

    // Mock data for UI demonstration
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _searchResults = {
        "query": query,
        "total_results": 4,
        "sections": {
          "events": {
            "count": 2,
            "title": "Matches",
            "results": [
              {
                "event_id": "1",
                "event_name": "Bayern Munich vs RB Leipzig",
                "event_date": "2025-11-22T14:30:00Z",
                "event_status": "Not Started",
                "event_round": "11",
                "home_team_logo":
                    "https://r2.thesportsdb.com/images/media/team/badge/01ogkh1716960412.png",
                "away_team_logo":
                    "https://r2.thesportsdb.com/images/media/team/badge/zjgapo1594244951.png",
                "contract_deployed": true,
              },
              {
                "event_id": "2",
                "event_name": "Bayern Munich vs Freiburg",
                "event_date": "2025-11-29T14:30:00Z",
                "event_status": "Not Started",
                "event_round": "12",
                "home_team_logo":
                    "https://r2.thesportsdb.com/images/media/team/badge/01ogkh1716960412.png",
                "away_team_logo":
                    "https://r2.thesportsdb.com/images/media/team/badge/urwtup1473453288.png",
                "contract_deployed": false,
              },
            ],
          },
          "teams": {
            "count": 1,
            "title": "Teams",
            "results": [
              {
                "team_id": "133664",
                "team_name": "Bayern Munich",
                "team_badge":
                    "https://r2.thesportsdb.com/images/media/team/badge/01ogkh1716960412.png",
                "team_country": "Germany",
                "form_last_5": "W-W-W-W-W",
                "form_goals_scored": 4.0,
              },
            ],
          },
        },
      };
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Container(
        color: const Color(0xFF0F1419),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  _buildSearchHeader(),
                  Expanded(child: _buildSearchContent()),
                ],
              ),
              // Back button (positioned absolutely like home page)
              Positioned(
                top: 70,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha: 0.05),
                      highlightColor: Colors.white.withValues(alpha: 0.02),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(20, 65, 20, 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: Colors.white,
              cursorWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_query.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_searchResults == null ||
        (_searchResults!['total_results'] ?? 0) == 0) {
      return _buildNoResultsState();
    }

    return _buildSearchResults();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for events, teams, or leagues',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing to see results',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_query"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final sections = _searchResults!['sections'] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          child: Text(
            '${_searchResults!['total_results']} results for "$_query"',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),

        // Events Section
        if (sections.containsKey('events') &&
            (sections['events']['count'] ?? 0) > 0)
          _buildEventsSection(sections['events']),

        // Teams Section
        if (sections.containsKey('teams') &&
            (sections['teams']['count'] ?? 0) > 0)
          _buildTeamsSection(sections['teams']),

        // Leagues Section
        if (sections.containsKey('leagues') &&
            (sections['leagues']['count'] ?? 0) > 0)
          _buildLeaguesSection(sections['leagues']),

        // Players Section
        if (sections.containsKey('players') &&
            (sections['players']['count'] ?? 0) > 0)
          _buildPlayersSection(sections['players']),

        // Venues Section
        if (sections.containsKey('venues') &&
            (sections['venues']['count'] ?? 0) > 0)
          _buildVenuesSection(sections['venues']),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEventsSection(Map<String, dynamic> section) {
    final results = section['results'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section['title'], section['count']),
        const SizedBox(height: 12),
        ...results.map((event) => _buildEventCard(event)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTeamsSection(Map<String, dynamic> section) {
    final results = section['results'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section['title'], section['count']),
        const SizedBox(height: 12),
        ...results.map((team) => _buildTeamCard(team)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLeaguesSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section['title'], section['count']),
        const SizedBox(height: 12),
        // TODO: Build league cards
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlayersSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section['title'], section['count']),
        const SizedBox(height: 12),
        // TODO: Build player cards
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVenuesSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(section['title'], section['count']),
        const SizedBox(height: 12),
        // TODO: Build venue cards
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventName = event['event_name'] ?? 'Unknown Event';
    final teams = eventName.split(' vs ');
    final homeTeam = teams.isNotEmpty ? teams[0] : 'Home';
    final awayTeam = teams.length > 1 ? teams[1] : 'Away';
    final eventDate = event['event_date'] ?? '';
    final eventStatus = event['event_status'] ?? '';
    final homeTeamLogo = event['home_team_logo'];
    final awayTeamLogo = event['away_team_logo'];
    final contractDeployed = event['contract_deployed'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: contractDeployed
              ? () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          GameDetailsPage(eventId: event['event_id']),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A3544), width: 1),
            ),
            child: Row(
              children: [
                // Team Logos
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      if (homeTeamLogo != null)
                        _buildTeamLogo(homeTeamLogo, 24)
                      else
                        _buildPlaceholderLogo(24),
                      const SizedBox(width: 4),
                      if (awayTeamLogo != null)
                        _buildTeamLogo(awayTeamLogo, 24)
                      else
                        _buildPlaceholderLogo(24),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(eventDate),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: contractDeployed
                                  ? const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              contractDeployed ? 'Active' : eventStatus,
                              style: TextStyle(
                                color: contractDeployed
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    final teamName = team['team_name'] ?? 'Unknown Team';
    final teamCountry = team['team_country'] ?? '';
    final teamBadge = team['team_badge'];
    final formLast5 = team['form_last_5'] ?? '';
    final goalsScored = team['form_goals_scored'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Row(
        children: [
          // Team Badge
          if (teamBadge != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: CachedNetworkImage(
                imageUrl: teamBadge,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.sports_soccer, size: 24),
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 24,
              ),
            ),
          const SizedBox(width: 12),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (teamCountry.isNotEmpty) ...[
                      Text(
                        teamCountry,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (formLast5.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                    if (formLast5.isNotEmpty)
                      Text(
                        formLast5,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Goals Scored
          if (goalsScored != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${goalsScored.toStringAsFixed(1)} G/M',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(4),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) =>
            const Icon(Icons.sports_soccer, size: 12),
      ),
    );
  }

  Widget _buildPlaceholderLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.sports_soccer, color: Colors.white, size: 12),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
