import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/app_styles.dart';

@immutable
class QuickPickGameCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool isFavorite;
  final Function(String eventId, bool currentState) onFavoriteToggle;
  final VoidCallback onTap;

  const QuickPickGameCard({
    super.key,
    required this.match,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(minHeight: 70),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                    _buildTeamLogoContainer(match),
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
                            style: AppStyles.bodySmall.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final eventId = match['id'] as String;
                    onFavoriteToggle(eventId, isFavorite);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.grey[600],
                      size: 20,
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

  Widget _buildTeamLogoContainer(Map<String, dynamic> match) {
    final homeTeamLogo = match['homeTeamLogo'] as String?;
    final awayTeamLogo = match['awayTeamLogo'] as String?;
    final hasLogos = homeTeamLogo != null || awayTeamLogo != null;

    return Container(
      width: hasLogos ? 60 : 50,
      height: hasLogos ? 60 : 50,
      decoration: hasLogos
          ? null
          : BoxDecoration(
              color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF34495E).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
      child: _buildTeamLogo(match, hasLogos),
    );
  }

  Widget _buildTeamLogo(Map<String, dynamic> match, bool hasLogos) {
    final homeTeamLogo = match['homeTeamLogo'] as String?;
    final awayTeamLogo = match['awayTeamLogo'] as String?;

    // If we have logos, show them side by side
    if (hasLogos) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (homeTeamLogo != null)
              Expanded(child: _buildSingleLogo(homeTeamLogo)),
            if (awayTeamLogo != null)
              Expanded(child: _buildSingleLogo(awayTeamLogo)),
          ],
        ),
      );
    }

    // Default fallback icon
    return Icon(
      Icons.sports_soccer,
      color: Colors.white.withValues(alpha: 0.8),
      size: 20,
    );
  }

  Widget _buildSingleLogo(String logoUrl) {
    // Check if it's a network URL or local asset
    if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        errorWidget: (context, url, error) {
          return Icon(
            Icons.sports_soccer,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          );
        },
      );
    } else {
      return Image.asset(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sports_soccer,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          );
        },
      );
    }
  }
}
