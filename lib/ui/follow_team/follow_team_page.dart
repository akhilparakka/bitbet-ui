import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/domain/models/team_model.dart';
import 'package:bitbet/domain/services/team_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FollowTeamPage extends StatefulWidget {
  const FollowTeamPage({super.key});

  @override
  State<FollowTeamPage> createState() => _FollowTeamPageState();
}

class _FollowTeamPageState extends State<FollowTeamPage> {
  List<TeamModel> teams = [];
  List<TeamModel> filteredTeams = [];
  Set<int> selectedTeamIds = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _searchController.addListener(_filterTeams);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() {
      isLoading = true;
    });

    final apiService = TeamApiService();
    final fetchedTeams = await apiService.getTeams();

    setState(() {
      teams = fetchedTeams;
      filteredTeams = fetchedTeams;
      isLoading = false;
    });
  }

  void _filterTeams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredTeams = teams;
      } else {
        filteredTeams = teams.where((team) {
          return team.teamName.toLowerCase().contains(query) ||
              team.teamCountry.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _toggleTeam(int teamId) {
    setState(() {
      if (selectedTeamIds.contains(teamId)) {
        selectedTeamIds.remove(teamId);
      } else {
        selectedTeamIds.add(teamId);
      }
    });
  }

  void _handleNext() {
    // Navigate to home page
    // You can save selected teams to SharedPreferences here if needed
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          // Navigate back to follow league page instead of closing app
          Navigator.pushReplacementNamed(context, AppRoutes.followLeague);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favourite Club',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.09,
                      height: 26 / 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select to follow one or teams. These will appear in your favourites tab.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8E8E93),
                      letterSpacing: 0.07,
                      height: 22 / 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Search field
                  _buildSearchField(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Team list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF2882),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = filteredTeams[index];
                        final isSelected =
                            selectedTeamIds.contains(team.teamId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTeamItem(team, isSelected),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(28, 28, 30, 0.48),
              Color(0xFF1C1C1E),
            ],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: _buildNextButton(),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF38384C)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.07,
        ),
        decoration: const InputDecoration(
          hintText: 'Search club...',
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8E8E93),
            letterSpacing: 0.07,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF8E8E93),
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTeamItem(TeamModel team, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleTeam(team.teamId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Team logo with container for breathing space
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: team.teamLogo,
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.sports_soccer,
                    size: 26,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Team name
            Expanded(
              child: Text(
                team.teamName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.07,
                  height: 22 / 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF00C566)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00C566)
                      : const Color(0xFF8E8E93),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _handleNext,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF2882),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Next',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.07,
            height: 22 / 14,
          ),
        ),
      ),
    );
  }
}
