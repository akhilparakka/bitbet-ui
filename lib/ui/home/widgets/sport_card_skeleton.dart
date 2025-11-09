import 'package:flutter/material.dart';

class SportCardSkeleton extends StatelessWidget {
  const SportCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
