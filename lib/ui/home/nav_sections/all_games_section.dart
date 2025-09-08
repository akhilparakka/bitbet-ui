import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/odds_provider.dart';
import '../../../domain/providers/leagues_provider.dart';
import '../../../domain/providers/sports_provider.dart';
import '../../../domain/providers/user_provider.dart';
import '../game_details/game_details_page.dart';

class AllGamesSection extends StatefulWidget {
  const AllGamesSection({super.key});

  @override
  State<AllGamesSection> createState() => _AllGamesSectionState();
}

class _AllGamesSectionState extends State<AllGamesSection> {
  Set<String> favoriteEventIds = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          // Quick picks header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Quick picks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Quick picks content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final quickPicsAsync = ref.watch(
                    quickPicsWithFavoritesProvider,
                  );
                  return quickPicsAsync.when(
                    data: (matches) {
                      // Initialize local favorites from fetched data
                      if (favoriteEventIds.isEmpty) {
                        favoriteEventIds = matches
                            .where((match) => match['isFavorite'] == true)
                            .map((match) => match['id'] as String)
                            .toSet();
                      }
                      return Column(
                        children: matches
                            .map((match) => _buildQuickPickItem(match, ref))
                            .toList(),
                      );
                    },
                    loading: () => Column(
                      children: List.generate(
                        4,
                        (index) => _buildQuickPickSkeleton(),
                      ),
                    ),
                    error: (error, stack) => Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),

          // Popular leagues header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Popular leagues',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Popular leagues content
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Consumer(
                builder: (context, ref, child) {
                  final leaguesAsync = ref.watch(leaguesProvider);
                  return leaguesAsync.when(
                    data: (leagues) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: leagues.length,
                      itemBuilder: (context, index) {
                        return _buildLeagueCard(leagues[index]);
                      },
                    ),
                    loading: () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return _buildLeagueCardSkeleton();
                      },
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading leagues: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Other sports header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Other sports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Other sports content
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170,
              child: Consumer(
                builder: (context, ref, child) {
                  final sportsAsync = ref.watch(sportsProvider);
                  return sportsAsync.when(
                    data: (sports) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 0,
                        right: 20,
                        bottom: 0,
                      ),
                      itemCount: sports.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: _buildSportCard(sports[index]),
                        );
                      },
                    ),
                    loading: () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 0,
                        right: 20,
                        bottom: 0,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: _buildSportCardSkeleton(),
                        );
                      },
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading sports: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildQuickPickItem(Map<String, dynamic> match, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(minHeight: 70),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const GameDetailsPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            );
          },
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF34495E).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: Colors.white.withValues(alpha: 0.8),
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
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            match['league'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              if (match['odds']['home'] != 'N/A')
                                _buildOddsChip(match['odds']['home']),
                              if (match['odds']['draw'] != 'N/A') ...[
                                const SizedBox(width: 4),
                                _buildOddsChip(match['odds']['draw']),
                              ],
                              if (match['odds']['away'] != 'N/A') ...[
                                const SizedBox(width: 4),
                                _buildOddsChip(match['odds']['away']),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final eventId = match['id'] as String;
                    final isCurrentlyFavorite = favoriteEventIds.contains(
                      eventId,
                    );
                    setState(() {
                      if (isCurrentlyFavorite) {
                        favoriteEventIds.remove(eventId);
                      } else {
                        favoriteEventIds.add(eventId);
                      }
                    });
                    // Call API
                    final userId = await ref.read(userIdProvider.future);
                    if (userId == null) {
                      // Revert the optimistic update
                      setState(() {
                        if (isCurrentlyFavorite) {
                          favoriteEventIds.add(eventId);
                        } else {
                          favoriteEventIds.remove(eventId);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to add favorites')),
                      );
                      return;
                    }
                    final userService = ref.read(userApiServiceProvider);
                    debugPrint("Adding favorite for userId: $userId, eventId: $eventId");
                    final success = await userService.addFavorite(
                      userId,
                      eventId,
                    );
                    if (!success) {
                      // Revert on failure
                      setState(() {
                        if (isCurrentlyFavorite) {
                          favoriteEventIds.add(eventId);
                        } else {
                          favoriteEventIds.remove(eventId);
                        }
                      });
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update favorite'),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    favoriteEventIds.contains(match['id'])
                        ? Icons.star
                        : Icons.star_border,
                    color: favoriteEventIds.contains(match['id'])
                        ? Colors.yellow
                        : Colors.grey[600],
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPickSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(minHeight: 70),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF34495E).withValues(alpha: 0.5),
                      const Color(0xFF2C3E50).withValues(alpha: 0.6),
                      const Color(0xFF34495E).withValues(alpha: 0.5),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              // Space for potential live indicator
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF34495E).withValues(alpha: 0.5),
                        const Color(0xFF2C3E50).withValues(alpha: 0.6),
                        const Color(0xFF34495E).withValues(alpha: 0.5),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF34495E).withValues(alpha: 0.5),
                            const Color(0xFF2C3E50).withValues(alpha: 0.6),
                            const Color(0xFF34495E).withValues(alpha: 0.5),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Space for potential LIVE badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      width: 30,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34495E).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          width: 24,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2C3E50,
                            ).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF34495E).withValues(alpha: 0.5),
                                const Color(0xFF2C3E50).withValues(alpha: 0.6),
                                const Color(0xFF34495E).withValues(alpha: 0.5),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                  const Color(0xFF2C3E50).withValues(alpha: 0.6),
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
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
        color: const Color(0xFF34495E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
          width: 1,
        ),
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
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF34495E).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.sports,
              color: Colors.white.withValues(alpha: 0.7),
              size: 40,
            ),
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

  Widget _buildLeagueCardSkeleton() {
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
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                  const Color(0xFF2C3E50).withValues(alpha: 0.6),
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                  const Color(0xFF2C3E50).withValues(alpha: 0.6),
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                  const Color(0xFF2C3E50).withValues(alpha: 0.6),
                  const Color(0xFF34495E).withValues(alpha: 0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sport) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF34495E).withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.sports,
            color: Colors.white.withValues(alpha: 0.8),
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sport['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSportCardSkeleton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF34495E).withValues(alpha: 0.3),
              width: 2,
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2C3E50).withValues(alpha: 0.5),
                const Color(0xFF34495E).withValues(alpha: 0.7),
                const Color(0xFF2C3E50).withValues(alpha: 0.5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 16,
          width: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF34495E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2C3E50).withValues(alpha: 0.5),
                const Color(0xFF34495E).withValues(alpha: 0.7),
                const Color(0xFF2C3E50).withValues(alpha: 0.5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
