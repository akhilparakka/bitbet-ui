import 'package:flutter/material.dart';

class QuickPickSkeleton extends StatelessWidget {
  const QuickPickSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
                  height: 32,
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
}
