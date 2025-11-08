import 'package:flutter/material.dart';
import '../../../domain/models/transaction_preview.dart';
import '../../common/app_styles.dart';

class TransactionPreviewSheet extends StatelessWidget {
  final TransactionPreview preview;
  final VoidCallback onProceed;
  final VoidCallback onCancel;
  final bool isProcessing;

  const TransactionPreviewSheet({
    super.key,
    required this.preview,
    required this.onProceed,
    required this.onCancel,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Transaction',
                  style: AppStyles.headerSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: isProcessing ? null : onCancel,
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Betting On
                _buildRow('Betting On', preview.betType, highlight: true),
                const SizedBox(height: 16),

                // Amount
                _buildRow(
                  'Amount',
                  '${preview.formattedBetAmount} ${preview.tokenSymbol}',
                ),
                const SizedBox(height: 16),

                // Potential Payout
                _buildRow(
                  'Potential Win',
                  '~${preview.formattedPotentialPayout} ${preview.tokenSymbol}',
                  valueColor: Colors.greenAccent,
                ),
                const SizedBox(height: 16),

                // Gas Fee
                _buildRow('Gas Fee', '~${preview.formattedGasCost} ETH'),
                const SizedBox(height: 24),

                // Contract Info (Compact)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1419),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Market: ${preview.shortMarketAddress}',
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppStyles.bodyLarge.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : onProceed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Confirm',
                            style: AppStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool highlight = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: AppStyles.bodyMedium.copyWith(
            color:
                valueColor ??
                (highlight ? const Color(0xFF6C63FF) : Colors.white),
            fontSize: 15,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
