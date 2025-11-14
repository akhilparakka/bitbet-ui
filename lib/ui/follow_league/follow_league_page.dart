import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/domain/models/league_model.dart';
import 'package:bitbet/domain/services/league_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FollowLeaguePage extends StatefulWidget {
  const FollowLeaguePage({super.key});

  @override
  State<FollowLeaguePage> createState() => _FollowLeaguePageState();
}

class _FollowLeaguePageState extends State<FollowLeaguePage> {
  List<LeagueModel> leagues = [];
  List<LeagueModel> filteredLeagues = [];
  Set<int> selectedLeagueIds = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLeagues();
    _searchController.addListener(_filterLeagues);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLeagues() async {
    setState(() {
      isLoading = true;
    });

    final apiService = LeagueApiService();
    final fetchedLeagues = await apiService.getLeagues();

    setState(() {
      leagues = fetchedLeagues;
      filteredLeagues = fetchedLeagues;
      isLoading = false;
    });
  }

  void _filterLeagues() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredLeagues = leagues;
      } else {
        filteredLeagues = leagues.where((league) {
          return league.leagueName.toLowerCase().contains(query) ||
              league.leagueCountryName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _toggleLeague(int leagueId) {
    setState(() {
      if (selectedLeagueIds.contains(leagueId)) {
        selectedLeagueIds.remove(leagueId);
      } else {
        selectedLeagueIds.add(leagueId);
      }
    });
  }

  void _handleNext() {
    // Navigate to follow team page
    // You can save selected leagues to SharedPreferences here if needed
    Navigator.pushReplacementNamed(context, AppRoutes.followTeam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Follow League',
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

            // League list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF2882),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filteredLeagues.length,
                      itemBuilder: (context, index) {
                        final league = filteredLeagues[index];
                        final isSelected =
                            selectedLeagueIds.contains(league.leagueId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildLeagueItem(league, isSelected),
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
          hintText: 'Search league...',
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

  Widget _buildLeagueItem(LeagueModel league, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleLeague(league.leagueId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // League logo with container for breathing space
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: league.leagueLogo,
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
            // League name
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      league.leagueName,
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
                  const SizedBox(width: 6),
                  Text(
                    '(${league.leagueCountryName})',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E8E93),
                      letterSpacing: 0.06,
                      height: 16 / 12,
                    ),
                  ),
                ],
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
