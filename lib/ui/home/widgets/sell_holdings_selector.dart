import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/user_bets_provider.dart';
import '../../custom_widgets/shimmer_widget.dart';
import '../../common/app_styles.dart';

class SellHoldingsSelector extends ConsumerWidget {
  final Map<String, dynamic>? eventData;
  final Map<String, dynamic>? pricingData;
  final String selectedOutcome;
  final Function(String outcome, BigInt amount) onOutcomeSelected;
  final String? userId;
  final String eventId;

  const SellHoldingsSelector({
    super.key,
    required this.eventData,
    required this.pricingData,
    required this.selectedOutcome,
    required this.onOutcomeSelected,
    required this.userId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return Center(
        child: Text(
          'Please login to view holdings',
          style: AppStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
      );
    }

    final userBetsAsync = ref.watch(userBetsProvider(userId!));

    // Show skeleton loaders while loading
    if (userBetsAsync.isLoading) {
      return Row(
        children: [
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerWidget(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3544),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 18,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 17,
                      width: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4554),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final holdings = userBetsAsync.value?['holdings'] as List<dynamic>?;
    final marketHoldings = _getHoldingsForMarket(holdings, eventId);
    final hasAnyHoldings = marketHoldings.values.any((holding) => holding > 0);

    if (!hasAnyHoldings) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No tokens to sell',
            style: AppStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ),
      );
    }

    final homeTeam =
        (eventData!['home_team'] as List?)?.first?['team_name'] ??
        eventData!['home_team_name'] ??
        'Home';
    final awayTeam =
        (eventData!['away_team'] as List?)?.first?['team_name'] ??
        eventData!['away_team_name'] ??
        'Away';

    return Column(
      children: [
        Row(
          children: [
            if (marketHoldings['home']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  homeTeam.substring(0, 3).toUpperCase(),
                  'home',
                  marketHoldings['home']!,
                  pricingData,
                ),
              ),
            if (marketHoldings['home']! > 0) const SizedBox(width: 8),
            if (marketHoldings['draw']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  'DRW',
                  'draw',
                  marketHoldings['draw']!,
                  pricingData,
                ),
              ),
            if (marketHoldings['draw']! > 0 && marketHoldings['away']! > 0)
              const SizedBox(width: 8),
            if (marketHoldings['away']! > 0)
              Expanded(
                child: _buildSellHoldingOption(
                  awayTeam.substring(0, 3).toUpperCase(),
                  'away',
                  marketHoldings['away']!,
                  pricingData,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Map<String, double> _getHoldingsForMarket(
    List<dynamic>? holdings,
    String eventId,
  ) {
    final Map<String, double> marketHoldings = {
      'home': 0.0,
      'draw': 0.0,
      'away': 0.0,
    };

    if (holdings == null) return marketHoldings;

    for (final holding in holdings) {
      if (holding.eventId == eventId) {
        final outcomeKey = holding.outcomeIndex == 0
            ? 'home'
            : holding.outcomeIndex == 1
            ? 'draw'
            : 'away';
        final shares = double.tryParse(holding.shares) ?? 0.0;
        marketHoldings[outcomeKey] = marketHoldings[outcomeKey]! + shares;
      }
    }

    return marketHoldings;
  }

  Widget _buildSellHoldingOption(
    String teamAbbr,
    String outcome,
    double holdingAmount,
    Map<String, dynamic>? pricingData,
  ) {
    final isSelected = selectedOutcome == outcome;

    return GestureDetector(
      onTap: () {
        // Reset sell amount when changing outcome by passing BigInt.zero
        onOutcomeSelected(outcome, BigInt.zero);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF2A3544),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purple.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              teamAbbr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (holdingAmount / 1e18).toStringAsFixed(2),
              style: AppStyles.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'shares',
              style: AppStyles.captionSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
