import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/odds_provider.dart';
import '../../../domain/providers/user_provider.dart';
import '../game_details/game_details_page.dart';

class FavoritesSection extends StatefulWidget {
  const FavoritesSection({super.key});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
  Map<String, bool> favoriteMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Your Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Games you\'ve marked as favorites',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Favorites Grid
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final quickPicsAsync = ref.watch(quickPicsWithFavoritesProvider);
                  return quickPicsAsync.when(
                    data: (matches) {
                      // Filter only favorite matches
                      final favoriteMatches = matches
                          .where((match) => match['isFavorite'] == true)
                          .toList();

                      // Initialize local favorites from fetched data
                      final fetchedFavorites = favoriteMatches
                          .where((match) => match['isFavorite'] == true)
                          .map((match) => match['id'] as String)
                          .toSet();
                      debugPrint("Fetched favorites: $fetchedFavorites");

                      for (var match in matches) {
                        // Always update favoriteMap with latest data from server
                        favoriteMap[match['id']] = fetchedFavorites.contains(match['id']);
                      }
                      debugPrint("Local favoriteMap: $favoriteMap");

                      if (favoriteMatches.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: [
                          // Create 2x2 grid
                          for (int row = 0; row < (favoriteMatches.length / 2).ceil(); row++) ...[
                            Row(
                              children: [
                                for (int col = 0; col < 2; col++) ...[
                                  Expanded(
                                    child: _buildFavoriteCard(
                                      favoriteMatches.length > (row * 2 + col)
                                          ? favoriteMatches[row * 2 + col]
                                          : null,
                                      ref,
                                    ),
                                  ),
                                  if (col == 0) const SizedBox(width: 16),
                                ],
                              ],
                            ),
                            if (row < (favoriteMatches.length / 2).ceil() - 1)
                              const SizedBox(height: 16),
                          ],
                        ],
                      );
                    },
                    loading: () => _buildLoadingState(),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading favorites: $error',
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

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark games as favorites to see them here',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        for (int row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (int col = 0; col < 2; col++) ...[
                Expanded(
                  child: _buildFavoriteCardSkeleton(),
                ),
                if (col == 0) const SizedBox(width: 16),
              ],
            ],
          ),
          if (row < 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic>? match, WidgetRef ref) {
    if (match == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const GameDetailsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            );
          },
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF34495E).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // League and Live indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match['league'] ?? 'Unknown League',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match['isLive'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                const SizedBox(height: 8),

                // Teams
                Text(
                  '${match['homeTeam']} vs ${match['awayTeam']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Odds
                if (match['odds'] != null && match['odds']['home'] != 'N/A') ...[
                  Row(
                    children: [
                      _buildOddsChip(match['odds']['home']),
                      const SizedBox(width: 8),
                      if (match['odds']['draw'] != 'N/A') ...[
                        _buildOddsChip(match['odds']['draw']),
                        const SizedBox(width: 8),
                      ],
                      if (match['odds']['away'] != 'N/A')
                        _buildOddsChip(match['odds']['away']),
                    ],
                  ),
                ],

                const Spacer(),

                // Favorite toggle
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final eventId = match['id'] as String;
                      final isCurrentlyFavorite = favoriteMap[eventId] ?? false;
                      setState(() {
                        favoriteMap[eventId] = !isCurrentlyFavorite;
                      });

                      final userId = await ref.read(userIdProvider.future);
                      if (userId == null) {
                        setState(() {
                          favoriteMap[eventId] = isCurrentlyFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to manage favorites')),
                        );
                        return;
                      }

                      final userService = ref.read(userApiServiceProvider);
                      bool success;
                      if (isCurrentlyFavorite) {
                        success = await userService.removeFavorite(userId, eventId);
                      } else {
                        success = await userService.addFavorite(userId, eventId);
                      }

                      if (success) {
                        ref.invalidate(favoritesProvider);
                        ref.invalidate(quickPicsWithFavoritesProvider);
                      } else {
                        setState(() {
                          favoriteMap[eventId] = isCurrentlyFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update favorite')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        (favoriteMap[match['id']] ?? false) ? Icons.star : Icons.star_border,
                        color: (favoriteMap[match['id']] ?? false) ? Colors.yellow : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCardSkeleton() {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF34495E).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League skeleton
            Container(
              height: 12,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF34495E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),

            // Teams skeleton
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF34495E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF34495E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),

            // Odds skeleton
            Row(
              children: [
                Container(
                  height: 20,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Star skeleton
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF34495E).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOddsChip(String odds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        odds,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}