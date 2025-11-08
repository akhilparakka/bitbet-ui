import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/app_styles.dart';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  String _selectedPeriod = 'weekly'; // daily, weekly, all_time

  // TODO: Replace with real API data
  final List<Map<String, dynamic>> _mockLeaderboardData = [
    {
      'rank': 1,
      'userId': '1',
      'name': 'Albert Flores',
      'imageUrl': 'https://i.pravatar.cc/150?img=12',
      'points': 2847,
      'profit': 1250.50,
      'winRate': 68.5,
      'totalBets': 127,
    },
    {
      'rank': 2,
      'userId': '2',
      'name': 'Bessie Cooper',
      'imageUrl': 'https://i.pravatar.cc/150?img=45',
      'points': 2654,
      'profit': 1100.25,
      'winRate': 65.2,
      'totalBets': 98,
    },
    {
      'rank': 3,
      'userId': '3',
      'name': 'Devon Lane',
      'imageUrl': 'https://i.pravatar.cc/150?img=33',
      'points': 2401,
      'profit': 980.75,
      'winRate': 62.8,
      'totalBets': 85,
    },
    {
      'rank': 4,
      'userId': '4',
      'name': 'Esther Howard',
      'imageUrl': 'https://i.pravatar.cc/150?img=20',
      'points': 2198,
      'profit': 850.00,
      'winRate': 60.5,
      'totalBets': 72,
    },
    {
      'rank': 5,
      'userId': '5',
      'name': 'Leslie Alexander',
      'imageUrl': 'https://i.pravatar.cc/150?img=15',
      'points': 2087,
      'profit': 780.50,
      'winRate': 58.9,
      'totalBets': 68,
    },
    {
      'rank': 6,
      'userId': '6',
      'name': 'Kristin Watson',
      'imageUrl': 'https://i.pravatar.cc/150?img=25',
      'points': 1956,
      'profit': 720.25,
      'winRate': 57.3,
      'totalBets': 64,
    },
    {
      'rank': 7,
      'userId': '7',
      'name': 'Albert Flores',
      'imageUrl': 'https://i.pravatar.cc/150?img=8',
      'points': 1834,
      'profit': 650.00,
      'winRate': 55.7,
      'totalBets': 59,
    },
    {
      'rank': 8,
      'userId': '8',
      'name': 'Cameron Williamson',
      'imageUrl': 'https://i.pravatar.cc/150?img=51',
      'points': 1723,
      'profit': 590.75,
      'winRate': 54.2,
      'totalBets': 55,
    },
    {
      'rank': 9,
      'userId': '9',
      'name': 'Brooklyn Simmons',
      'imageUrl': 'https://i.pravatar.cc/150?img=40',
      'points': 1612,
      'profit': 530.50,
      'winRate': 52.8,
      'totalBets': 51,
    },
    {
      'rank': 10,
      'userId': '10',
      'name': 'Wade Warren',
      'imageUrl': 'https://i.pravatar.cc/150?img=60',
      'points': 1505,
      'profit': 475.25,
      'winRate': 51.5,
      'totalBets': 48,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          // Period Selector
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A3544), width: 1),
              ),
              child: Row(
                children: [
                  _buildPeriodTab('Daily', 'daily'),
                  _buildPeriodTab('Weekly', 'weekly'),
                  _buildPeriodTab('All Time', 'all_time'),
                ],
              ),
            ),
          ),

          // Top 3 Podium
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildPodium(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Ranks 4-10
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final user =
                    _mockLeaderboardData[index + 3]; // Start from rank 4
                return _buildLeaderboardCard(user);
              }, childCount: _mockLeaderboardData.length - 3),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            // TODO: Fetch new data based on period
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppStyles.bodyMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _mockLeaderboardData.take(3).toList();

    // Reorder for podium display: [2nd, 1st, 3rd]
    final second = top3[1];
    final first = top3[0];
    final third = top3[2];

    return Column(
      children: [
        // Winner in center
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd Place
            _buildPodiumPosition(second, 2, 120),
            const SizedBox(width: 12),
            // 1st Place (tallest)
            _buildPodiumPosition(first, 1, 150),
            const SizedBox(width: 12),
            // 3rd Place
            _buildPodiumPosition(third, 3, 100),
          ],
        ),
      ],
    );
  }

  Widget _buildPodiumPosition(
    Map<String, dynamic> user,
    int position,
    double height,
  ) {
    Color podiumColor;

    switch (position) {
      case 1:
        podiumColor = const Color(0xFFFFD700); // Gold
        break;
      case 2:
        podiumColor = const Color(0xFFC0C0C0); // Silver
        break;
      case 3:
        podiumColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        podiumColor = Colors.grey;
    }

    return Column(
      children: [
        // Profile image with crown for 1st
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: podiumColor, width: 3),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user['imageUrl'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ),
            if (position == 1)
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: podiumColor,
                    size: 32,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black45),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Name
        SizedBox(
          width: 80,
          child: Text(
            user['name'],
            textAlign: TextAlign.center,
            style: AppStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Points
        Text(
          '${user['points']} pts',
          style: AppStyles.captionSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        // Podium stand
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: podiumColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: podiumColor, width: 2),
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: AppStyles.numberLarge.copyWith(
                color: podiumColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(Map<String, dynamic> user) {
    final rank = user['rank'];
    final isTopTen = rank <= 10;

    // Medal colors for ranks 4-10
    Color? medalColor;
    if (rank == 4) medalColor = const Color(0xFF6C63FF); // Purple
    if (rank == 5) medalColor = const Color(0xFF10B981); // Green
    if (rank == 6) medalColor = const Color(0xFFF59E0B); // Orange
    if (rank >= 7) medalColor = const Color(0xFF8B5CF6); // Light purple

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
          // Rank number
          SizedBox(
            width: 40,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Profile image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A3544), width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user['imageUrl'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user['points']} points',
                  style: AppStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Medal/Trophy icon
          if (isTopTen && medalColor != null)
            Icon(Icons.emoji_events, color: medalColor, size: 28),
        ],
      ),
    );
  }
}
