import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/event_provider.dart';
import '../../custom_widgets/navigation_sidebar.dart';

class TeamFormPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;
  final String homeTeamName;
  final String awayTeamName;

  const TeamFormPage({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  ConsumerState<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends ConsumerState<TeamFormPage> {
  late String selectedTeam;
  late List<Map<String, String>> _navData;

  @override
  void initState() {
    super.initState();
    selectedTeam = widget.homeTeamName;
    _navData = [
      {'name': widget.homeTeamName, 'icon': 'assets/svg/games.svg'},
      {'name': widget.awayTeamName, 'icon': 'assets/svg/games.svg'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final teamFormAsync = ref.watch(teamFormProvider(widget.eventId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF253342),
              Color(0xFF1F2937),
              Color(0xFF0F1419),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Row(
                children: [
                  CustomNavigationSidebar(
                    selectedSection: selectedTeam,
                    onSectionChanged: _onTeamChanged,
                    navData: _navData,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const CustomHeader(title: 'Stats'),
                        Expanded(
                          child: teamFormAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text(
                                'Error loading team form: $error',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            data: (teamFormData) {
                              if (teamFormData == null) {
                                return const Center(
                                  child: Text(
                                    'Team form not available',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }
                              return _buildTeamStats(teamFormData);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Future<void> _onTeamChanged(String team) async {
    if (selectedTeam == team) return;
    setState(() {
      selectedTeam = team;
    });
  }

  Widget _buildTeamStats(Map<String, dynamic> teamFormData) {
    final homeTeam = teamFormData['home_team'] as Map<String, dynamic>?;
    final awayTeam = teamFormData['away_team'] as Map<String, dynamic>?;

    Map<String, dynamic>? currentTeam;
    bool isHome = false;

    if (selectedTeam == widget.homeTeamName && homeTeam != null) {
      currentTeam = homeTeam;
      isHome = true;
    } else if (selectedTeam == widget.awayTeamName && awayTeam != null) {
      currentTeam = awayTeam;
      isHome = false;
    }

    if (currentTeam == null) {
      return Center(
        child: Text(
          'No stats available for $selectedTeam',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTeamSection(context, currentTeam, isHome: isHome)],
      ),
    );
  }

  Widget _buildTeamSection(
    BuildContext context,
    Map<String, dynamic> team, {
    required bool isHome,
  }) {
    final teamName = team['team_name'] as String? ?? 'Unknown Team';
    final teamBadge = team['team_badge'] as String?;
    final formLast5 = team['form_last_5'] as String? ?? '';
    final formGoalsScored = team['form_goals_scored'] ?? 0.0;
    final formGoalsConceded = team['form_goals_conceded'] ?? 0.0;
    final recentMatches = team['recent_matches'] as List? ?? [];
    final homeForm = team['home_form'] as Map<String, dynamic>?;
    final awayForm = team['away_form'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHome
                  ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                  : [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    (isHome ? const Color(0xFF4A90E2) : const Color(0xFFE74C3C))
                        .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (teamBadge != null && teamBadge.isNotEmpty)
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    teamBadge,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.sports_soccer, size: 40);
                    },
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHome ? 'Home Team' : 'Away Team',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overall Form (Last 5)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildFormIndicator(formLast5),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Goals Scored',
                      formGoalsScored.toStringAsFixed(1),
                      Colors.green,
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Goals Conceded',
                      formGoalsConceded.toStringAsFixed(1),
                      Colors.red,
                      Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (homeForm != null)
              Expanded(child: _buildFormStatsCard('Home', homeForm, isHome)),
            if (homeForm != null && awayForm != null) const SizedBox(width: 12),
            if (awayForm != null)
              Expanded(child: _buildFormStatsCard('Away', awayForm, isHome)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Matches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...recentMatches.map(
                (match) =>
                    _buildMatchCard(match as Map<String, dynamic>, teamName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormIndicator(String form) {
    final results = form.split('-');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: results.map((result) {
        Color color;
        switch (result.trim().toUpperCase()) {
          case 'W':
            color = const Color(0xFF4CAF50);
            break;
          case 'D':
            color = const Color(0xFFFFC107);
            break;
          case 'L':
            color = const Color(0xFFF44336);
            break;
          default:
            color = Colors.grey;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              result.trim(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormStatsCard(
    String type,
    Map<String, dynamic> formData,
    bool isHome,
  ) {
    final played = formData['played'] ?? 0;
    final won = formData['won'] ?? 0;
    final drawn = formData['drawn'] ?? 0;
    final lost = formData['lost'] ?? 0;
    final goalsScored = formData['goals_scored'] ?? 0;
    final goalsConceded = formData['goals_conceded'] ?? 0;
    final form = formData['form'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isHome ? const Color(0xFF4A90E2) : const Color(0xFFE74C3C))
              .withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$type Form',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'P: $played | W: $won | D: $drawn | L: $lost',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'GF: $goalsScored | GA: $goalsConceded',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: form.split('').map((result) {
              Color color;
              switch (result.trim().toUpperCase()) {
                case 'W':
                  color = const Color(0xFF4CAF50);
                  break;
                case 'D':
                  color = const Color(0xFFFFC107);
                  break;
                case 'L':
                  color = const Color(0xFFF44336);
                  break;
                default:
                  color = Colors.grey;
              }
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    result.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, String mainTeamName) {
    final opponent = match['opponent'] as String? ?? '';
    final opponentBadge = match['opponent_badge'] as String?;
    final date = match['date'] as String? ?? '';
    final venue = match['venue'] as String? ?? '';
    final isHomeMatch = match['is_home'] as bool? ?? false;
    final goalsFor = match['goals_for'] ?? 0;
    final goalsAgainst = match['goals_against'] ?? 0;
    final result = match['result'] as String? ?? '';

    Color resultColor;
    switch (result.toUpperCase()) {
      case 'W':
        resultColor = const Color(0xFF4CAF50);
        break;
      case 'D':
        resultColor = const Color(0xFFFFC107);
        break;
      case 'L':
        resultColor = const Color(0xFFF44336);
        break;
      default:
        resultColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: resultColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (opponentBadge != null && opponentBadge.isNotEmpty)
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.network(
                    opponentBadge,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.sports_soccer, size: 20);
                    },
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.sports_soccer, size: 20),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs $opponent',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHomeMatch ? 'Home' : 'Away',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$goalsFor - $goalsAgainst',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  venue,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(60, 65, 20, 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
