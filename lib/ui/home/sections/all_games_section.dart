import 'package:flutter/material.dart';

class AllGamesSection extends StatefulWidget {
  const AllGamesSection({super.key});

  @override
  State<AllGamesSection> createState() => _AllGamesSectionState();
}

class _AllGamesSectionState extends State<AllGamesSection> {
  final List<Map<String, dynamic>> quickPicks = [
    {
      'homeTeam': 'Man City',
      'awayTeam': 'Liverpool',
      'homeTeamLogo': 'assets/images/man_city.png',
      'awayTeamLogo': 'assets/images/liverpool.png',
      'league': 'Premier League',
      'odds': {'home': '2.10', 'draw': '3.50', 'away': '1.80'},
      'isLive': false,
      'isFavorite': true,
    },
    {
      'homeTeam': 'Lakers',
      'awayTeam': 'Warriors',
      'homeTeamLogo': 'assets/images/lakers.png',
      'awayTeamLogo': 'assets/images/warriors.png',
      'league': 'NBA',
      'odds': {'home': '1.95', 'away': '1.85'},
      'isLive': true,
      'isFavorite': false,
    },
    {
      'homeTeam': 'Real Madrid',
      'awayTeam': 'Barcelona',
      'homeTeamLOGO': 'assets/images/real_madrid.png',
      'awayTeamLogo': 'assets/images/barcelona.png',
      'league': 'La Liga',
      'odds': {'home': '2.25', 'draw': '3.20', 'away': '2.90'},
      'isLive': false,
      'isFavorite': false,
    },
    {
      'homeTeam': 'Celtics',
      'awayTeam': 'Heat',
      'homeTeamLogo': 'assets/images/celtics.png',
      'awayTeamLogo': 'assets/images/heat.png',
      'league': 'NBA',
      'odds': {'home': '1.75', 'away': '2.05'},
      'isLive': false,
      'isFavorite': false,
    },
  ];

  // Sample data for related leagues/tournaments
  final List<Map<String, dynamic>> relatedLeagues = [
    {
      'name': 'Premier League',
      'image': 'assets/images/premier_league.png',
      'season': '2024',
    },
    {
      'name': 'Champions League',
      'image': 'assets/images/champions_league.png',
      'season': '2024',
    },
    {'name': 'NBA Finals', 'image': 'assets/images/nba.png', 'season': '2024'},
  ];

  // Sample data for similar sports/categories
  final List<Map<String, dynamic>> similarSports = [
    {'name': 'Tennis', 'image': 'assets/images/tennis.png'},
    {'name': 'Baseball', 'image': 'assets/images/baseball.png'},
    {'name': 'Hockey', 'image': 'assets/images/hockey.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF181818), // Matte black for AllGamesSection
      child: CustomScrollView(
        slivers: [
          // Quick picks section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF181818), // Matte black for Quick Picks
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick picks header
                  const Text(
                    'Quick picks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick picks list
                  ...quickPicks
                      .map((match) => _buildQuickPickItem(match))
                      .toList(),

                  const SizedBox(height: 40),

                  // Related leagues section
                  const Text(
                    'Popular leagues',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Related leagues horizontal scroll
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF181818), // Matte black for Popular Leagues
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: relatedLeagues.length,
                itemBuilder: (context, index) {
                  return _buildLeagueCard(relatedLeagues[index]);
                },
              ),
            ),
          ),

          // Similar sports section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF181818), // Matte black for Other Sports
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Other sports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Similar sports horizontal scroll
          SliverToBoxAdapter(
            child: Container(
              color: const Color(
                0xFF181818,
              ), // Matte black for Other Sports (continued)
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: similarSports.length,
                itemBuilder: (context, index) {
                  return _buildSportCard(similarSports[index]);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildQuickPickItem(Map<String, dynamic> match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team logos
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              if (match['isLive'])
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Match details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match['homeTeam']} vs ${match['awayTeam']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      match['league'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    if (match['isLive']) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Odds preview with Flexible to prevent overflow
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (match['odds']['home'] != null)
                  _buildOddsChip(match['odds']['home']),
                if (match['odds']['draw'] != null) ...[
                  const SizedBox(width: 2),
                  _buildOddsChip(match['odds']['draw']),
                ],
                if (match['odds']['away'] != null) ...[
                  const SizedBox(width: 2),
                  _buildOddsChip(match['odds']['away']),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Favorite icon
          GestureDetector(
            onTap: () {
              // Toggle favorite
            },
            child: Icon(
              match['isFavorite'] ? Icons.star : Icons.star_border,
              color: match['isFavorite'] ? Colors.blue : Colors.grey[600],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOddsChip(String odds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        odds,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLeagueCard(Map<String, dynamic> league) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.sports, color: Colors.grey[600], size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            league['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            league['season'],
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports, color: Colors.grey[600], size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            sport['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
