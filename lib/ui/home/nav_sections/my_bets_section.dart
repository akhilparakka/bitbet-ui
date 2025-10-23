import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/user_bets_provider.dart';
import '../../../domain/providers/user_provider.dart';
import '../../../core/utils/formatting_utils.dart';
import '../../../domain/models/bet_model.dart';
import '../../../domain/models/holding_model.dart';
import '../../../domain/models/event_model.dart';

class MyBetsSection extends StatefulWidget {
  const MyBetsSection({super.key});

  @override
  State<MyBetsSection> createState() => _MyBetsSectionState();
}

class _MyBetsSectionState extends State<MyBetsSection> {
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
                return const Center(
                  child: Text(
                    'Please log in to view your bets',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              final betsAsync = ref.watch(userBetsProvider(userId));

              return betsAsync.when(
                data: (data) => _buildBetsContent(data),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading bets: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBetsContent(Map<String, dynamic> data) {
    final bets = data['bets'] as List<BetModel>;
    final holdings = data['holdings'] as List<HoldingModel>;
    final events = data['events'] as Map<String, EventModel>;
    final totals = data['totals'] as Map<String, dynamic>;

    if (bets.isEmpty && holdings.isEmpty) {
      return const Center(
        child: Text(
          'No bets yet\nPlace your first bet to get started!',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Summary header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Bets: ${totals['totalBets']}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Total Spent: ${formatUSDT(totals['totalSpent'])}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Total Received: ${formatUSDT(totals['totalReceived'])}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        // Holdings section
        if (holdings.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Active Positions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildHoldingCard(holdings[index], events),
              childCount: holdings.length,
            ),
          ),
        ],

        // Bets history section
        if (bets.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Betting History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildBetCard(bets[index], events),
              childCount: bets.length,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHoldingCard(HoldingModel holding, Map<String, EventModel> events) {
    final event = events[holding.eventId];
    final outcomeName = event != null ? getOutcomeName(holding.outcomeIndex, event.outcomes) : 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF34495E).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$outcomeName - ${formatShares(holding.shares)} shares',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Match: ${event?.eventName ?? 'Unknown'}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Invested: ${formatUSDT(holding.totalSpent)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (holding.totalReceived != '0') ...[
            const SizedBox(height: 4),
            Text(
              'Received: ${formatUSDT(holding.totalReceived)}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBetCard(BetModel bet, Map<String, EventModel> events) {
    final event = events[bet.eventId];
    final outcomeName = event != null ? getOutcomeName(bet.outcomeIndex, event.outcomes) : 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF34495E).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$outcomeName - ${formatUSDT(bet.costOrProfit)} (${bet.type})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Match: ${event?.eventName ?? 'Unknown'}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${formatDate(bet.blockTimestamp)}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shares: ${formatShares(bet.shares)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (bet.fees != '0') ...[
            const SizedBox(height: 4),
            Text(
              'Fees: ${formatUSDT(bet.fees)}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}