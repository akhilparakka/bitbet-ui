import 'package:flutter/material.dart';

class LeagueCardSkeleton extends StatelessWidget {
  const LeagueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}
