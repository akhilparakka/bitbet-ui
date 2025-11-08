import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/user_provider.dart';
import '../../common/app_styles.dart';

class FavoritesSection extends StatefulWidget {
  const FavoritesSection({super.key});

  @override
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection> {
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
                children: [],
              ),
            ),
          ),

          // Favorites Grid
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final fullFavoritesAsync = ref.watch(fullFavoritesProvider);
                  return fullFavoritesAsync.when(
                     data: (favorites) {
                       if (favorites.isEmpty) {
                         return _buildEmptyState();
                       }

                       // Group favorites by sport_group
                       final Map<String, List<Map<String, dynamic>>>
                       groupedFavorites = {};
                       for (final favorite in favorites) {
                         final sportGroup = favorite['sport_group'] as String? ?? 'Unknown';
                         if (!groupedFavorites.containsKey(sportGroup)) {
                           groupedFavorites[sportGroup] = [];
                         }
                         groupedFavorites[sportGroup]!.add(favorite);
                       }

                       final sportGroups = groupedFavorites.keys.toList();

                       return Column(
                         children: [
                           // Create 2x2 grid for sport groups
                           for (
                             int row = 0;
                             row < (sportGroups.length / 2).ceil();
                             row++
                           ) ...[
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 for (int col = 0; col < 2; col++) ...[
                                   _buildSportGroupCard(
                                     sportGroups.length > (row * 2 + col)
                                         ? sportGroups[row * 2 + col]
                                         : null,
                                     groupedFavorites,
                                     ref,
                                   ),
                                   if (col == 0) const SizedBox(width: 16),
                                 ],
                               ],
                             ),
                             if (row < (sportGroups.length / 2).ceil() - 1)
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
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: AppStyles.headerSmall,
            ),
            const SizedBox(height: 8),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 2; col++) ...[
                _buildSportGroupCardSkeleton(),
                if (col == 0) const SizedBox(width: 16),
              ],
            ],
          ),
          if (row < 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSportGroupCard(
    String? sportGroup,
    Map<String, List<Map<String, dynamic>>> groupedFavorites,
    WidgetRef ref,
  ) {
    if (sportGroup == null) {
      return const SizedBox.shrink();
    }

    final favoritesInGroup = groupedFavorites[sportGroup] ?? [];
    final count = favoritesInGroup.length;

    return Container(
      width: 140,
      height: 140,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint("Tapped on $sportGroup with $count favorites");
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
                // Sport icon and title
                Row(
                  children: [
                    Icon(
                      _getSportIcon(sportGroup),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sportGroup,
                        style: AppStyles.headerSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Count of favorites
                Text(
                  '$count favorite${count == 1 ? '' : 's'}',
                  style: AppStyles.bodyMedium.copyWith(color: Colors.grey[400]),
                ),

                const Spacer(),

                // View details hint
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tap to view',
                        style: AppStyles.captionSmall.copyWith(
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSportIcon(String sportGroup) {
    switch (sportGroup.toLowerCase()) {
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'baseball':
        return Icons.sports_baseball;
      case 'football':
        return Icons.sports_football;
      case 'tennis':
        return Icons.sports_tennis;
      case 'cricket':
        return Icons.sports_cricket;
      case 'hockey':
        return Icons.sports_hockey;
      default:
        return Icons.sports;
    }
  }

  Widget _buildSportGroupCardSkeleton() {
    return Container(
      width: 140,
      height: 140,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
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
            // Sport icon and title skeleton
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34495E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Count skeleton
            Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF34495E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const Spacer(),

            // View details hint skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34495E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34495E).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
