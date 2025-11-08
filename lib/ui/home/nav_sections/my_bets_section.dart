import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/providers/user_bets_provider.dart';
import '../../../domain/providers/user_provider.dart';
import '../../../core/utils/formatting_utils.dart';
import '../../../domain/models/bet_model.dart';
import '../../../domain/models/holding_model.dart';
import '../../../domain/models/event_model.dart';
import '../../common/app_styles.dart';

class MyBetsSection extends StatefulWidget {
  const MyBetsSection({super.key});

  @override
  State<MyBetsSection> createState() => _MyBetsSectionState();
}

class _MyBetsSectionState extends State<MyBetsSection> {
  String _selectedTab = 'holdings'; // 'holdings' or 'history'

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Consumer(
        builder: (context, ref, child) {
          final userIdAsync = ref.watch(userIdProvider);

          return userIdAsync.when(
            data: (userId) {
              if (userId == null) {
                return _buildEmptyState(
                  icon: Icons.login,
                  title: 'Please log in',
                  subtitle:
                      'Sign in to view your bets and track your positions',
                );
              }

              final betsAsync = ref.watch(userBetsProvider(userId));

              return betsAsync.when(
                data: (data) => _buildBetsContent(data),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                ),
                error: (error, stack) => _buildEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading bets',
                  subtitle: error.toString(),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
            error: (error, stack) => _buildEmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: error.toString(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppStyles.headerSmall.copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBetsContent(Map<String, dynamic> data) {
    final bets = data['bets'] as List<BetModel>;
    final holdings = data['holdings'] as List<HoldingModel>;
    final events = data['events'] as Map<String, EventModel>;
    final totals = data['totals'] as Map<String, dynamic>;

    if (bets.isEmpty && holdings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_soccer,
        title: 'No bets yet',
        subtitle: 'Place your first bet to get started!',
      );
    }

    // Group holdings by event
    final holdingsByEvent = <String, List<HoldingModel>>{};
    for (final holding in holdings) {
      holdingsByEvent.putIfAbsent(holding.eventId, () => []).add(holding);
    }

    return Column(
      children: [
        // Summary Stats Card
        _buildSummaryCard(totals, holdings),
        const SizedBox(height: 20),

        // Tab Selector
        _buildTabSelector(holdings, bets),
        const SizedBox(height: 16),

        // Content based on selected tab
        Expanded(
          child: _selectedTab == 'holdings'
              ? _buildHoldingsView(holdingsByEvent, events)
              : _buildHistoryView(bets, events),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> totals,
    List<HoldingModel> holdings,
  ) {
    final totalSpent = weiToDouble(totals['totalSpent'] ?? '0');
    final totalReceived = weiToDouble(totals['totalReceived'] ?? '0');
    final pnl = totalReceived - totalSpent;
    final pnlPercent = totalSpent > 0 ? (pnl / totalSpent * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Portfolio',
                style: AppStyles.headerSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: holdings.isNotEmpty
                      ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${holdings.length} Active',
                  style: AppStyles.bodySmall.copyWith(
                    color: holdings.isNotEmpty
                        ? const Color(0xFF6C63FF)
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Invested',
                  value: '\$${totalSpent.toStringAsFixed(2)}',
                  color: Colors.white,
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2A3544)),
              Expanded(
                child: _buildStatItem(
                  label: 'Returns',
                  value: '\$${totalReceived.toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2A3544)),
              Expanded(
                child: _buildStatItem(
                  label: 'P&L',
                  value: pnl >= 0
                      ? '+\$${pnl.toStringAsFixed(2)}'
                      : '-\$${pnl.abs().toStringAsFixed(2)}',
                  color: pnl >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  subtitle: pnl >= 0
                      ? '+${pnlPercent.toStringAsFixed(1)}%'
                      : '${pnlPercent.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppStyles.captionSmall.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabSelector(List<HoldingModel> holdings, List<BetModel> bets) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Active Positions',
              count: holdings.length,
              isSelected: _selectedTab == 'holdings',
              onTap: () => setState(() => _selectedTab = 'holdings'),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'History',
              count: bets.length,
              isSelected: _selectedTab == 'history',
              onTap: () => setState(() => _selectedTab = 'history'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF2A3544),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: AppStyles.captionSmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsView(
    Map<String, List<HoldingModel>> holdingsByEvent,
    Map<String, EventModel> events,
  ) {
    if (holdingsByEvent.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No active positions',
        subtitle: 'Your active bets will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: holdingsByEvent.length,
      itemBuilder: (context, index) {
        final eventId = holdingsByEvent.keys.elementAt(index);
        final eventHoldings = holdingsByEvent[eventId]!;
        final event = events[eventId];

        return _buildHoldingEventCard(event, eventHoldings);
      },
    );
  }

  Widget _buildHoldingEventCard(
    EventModel? event,
    List<HoldingModel> holdings,
  ) {
    if (event == null) return const SizedBox.shrink();

    final homeTeam = event.homeTeam.isNotEmpty
        ? event.homeTeam.first['team_name'] as String?
        : 'Home';
    final awayTeam = event.awayTeam.isNotEmpty
        ? event.awayTeam.first['team_name'] as String?
        : 'Away';
    final homeTeamLogo = event.homeTeam.isNotEmpty
        ? event.homeTeam.first['team_badge'] as String?
        : null;
    final awayTeamLogo = event.awayTeam.isNotEmpty
        ? event.awayTeam.first['team_badge'] as String?
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
          ...holdings.map((holding) => _buildHoldingRow(holding, event)),
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

  Widget _buildHistoryView(
    List<BetModel> bets,
    Map<String, EventModel> events,
  ) {
    if (bets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No betting history',
        subtitle: 'Your transaction history will appear here',
      );
    }

    // Sort bets by timestamp (newest first)
    final sortedBets = List<BetModel>.from(bets)
      ..sort(
        (a, b) =>
            int.parse(b.blockTimestamp).compareTo(int.parse(a.blockTimestamp)),
      );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: sortedBets.length,
      itemBuilder: (context, index) {
        final bet = sortedBets[index];
        final event = events[bet.eventId];
        return _buildBetHistoryCard(bet, event);
      },
    );
  }

  Widget _buildBetHistoryCard(BetModel bet, EventModel? event) {
    final outcomeName = event != null
        ? getOutcomeName(bet.outcomeIndex, event.outcomes)
        : 'Unknown';
    final cost = weiToDouble(bet.costOrProfit);
    final shares = weiToDouble(bet.shares);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3544), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bet.type == 'Purchase'
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bet.type == 'Purchase' ? 'BUY' : 'SELL',
                  style: AppStyles.captionSmall.copyWith(
                    color: bet.type == 'Purchase'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event?.eventName ?? 'Unknown Event',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcomeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(bet.blockTimestamp),
                    style: AppStyles.captionSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
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
