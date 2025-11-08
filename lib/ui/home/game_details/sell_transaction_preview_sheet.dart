import 'package:flutter/material.dart';
import '../../../domain/models/transaction_preview.dart';
import '../../common/app_styles.dart';

class SellTransactionPreviewSheet extends StatelessWidget {
  final TransactionPreview preview;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const SellTransactionPreviewSheet({
    super.key,
    required this.preview,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.sell,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Token Sale',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Event details
          Text(
            preview.eventName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            preview.betType,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Transaction details
          _buildDetailRow('Selling', '${preview.shares} tokens'),
          _buildDetailRow('Estimated Proceeds', '\$${preview.potentialPayout.toStringAsFixed(2)}'),
          _buildDetailRow('Max Cost (with slippage)', '\$${preview.maxCost.toStringAsFixed(2)}'),
          _buildDetailRow('Network Fee', '~${preview.estimatedGasCost.toStringAsFixed(4)} ETH'),

          const SizedBox(height: 24),

          // Warning about fees
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3544),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Platform fees will be deducted from your proceeds.',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF2A3544),
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
                child: ElevatedButton(
                  onPressed: onProceed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sell Tokens',
                    style: AppStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}