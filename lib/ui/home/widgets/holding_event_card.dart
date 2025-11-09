import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/event_model.dart';
import '../../../domain/models/holding_model.dart';
import '../../../core/utils/formatting_utils.dart';
import '../../common/app_styles.dart';

@immutable
class HoldingEventCard extends StatelessWidget {
  final EventModel? event;
  final List<HoldingModel> holdings;
  final VoidCallback? onCardTap;

  const HoldingEventCard({
    super.key,
    required this.event,
    required this.holdings,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (event == null) return const SizedBox.shrink();

    final homeTeam = event!.homeTeam.isNotEmpty
        ? event!.homeTeam.first['team_name'] as String?
        : 'Home';
    final awayTeam = event!.awayTeam.isNotEmpty
        ? event!.awayTeam.first['team_name'] as String?
        : 'Away';
    final homeTeamLogo = event!.homeTeam.isNotEmpty
        ? event!.homeTeam.first['team_badge'] as String?
        : null;
    final awayTeamLogo = event!.awayTeam.isNotEmpty
        ? event!.awayTeam.first['team_badge'] as String?
        : null;

    // Calculate total for this event
    double totalInvested = 0;
    for (final holding in holdings) {
      totalInvested += weiToDouble(holding.totalSpent);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Column(
        children: [
          // Event Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Home Team
                Expanded(
                  child: Row(
                    children: [
                      if (homeTeamLogo != null && homeTeamLogo.isNotEmpty)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CachedNetworkImage(
                            imageUrl: homeTeamLogo,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.sports_soccer, size: 20),
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.sports_soccer, size: 20),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          homeTeam ?? 'Home',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // VS
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    'VS',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Away Team
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          awayTeam ?? 'Away',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (awayTeamLogo != null && awayTeamLogo.isNotEmpty)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CachedNetworkImage(
                            imageUrl: awayTeamLogo,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.sports_soccer, size: 20),
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.sports_soccer, size: 20),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A3544), height: 1),
          // Holdings for this event
          ...holdings.map((holding) => _buildHoldingRow(holding, event!)),
          // Total row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3544).withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Invested',
                  style: AppStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '\$${totalInvested.toStringAsFixed(2)}',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(HoldingModel holding, EventModel event) {
    final outcomeName = getOutcomeName(holding.outcomeIndex, event.outcomes);
    final shares = weiToDouble(holding.shares);
    final invested = weiToDouble(holding.totalSpent);
    final potential = shares; // Each share worth $1 if wins

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Outcome indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getOutcomeColor(holding.outcomeIndex),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Outcome details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outcomeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${shares.toStringAsFixed(2)} shares',
                  style: AppStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Investment details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${invested.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Win: \$${potential.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getOutcomeColor(int outcomeIndex) {
    switch (outcomeIndex) {
      case 0:
        return const Color(0xFF6C63FF); // Home - Purple
      case 1:
        return const Color(0xFFF59E0B); // Draw - Orange
      case 2:
        return const Color(0xFF10B981); // Away - Green
      default:
        return Colors.grey;
    }
  }
}
