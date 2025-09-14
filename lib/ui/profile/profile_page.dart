import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F2937),
            Color(0xFF253342),
            Color(0xFF1F2937),
            Color(0xFF0F1419),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 160), // space for back button
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.visibility_off_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$3,460,348',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '\$670  2%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.add,
                          label: 'Add Money',
                          color: const Color(0xFFE9D5FF),
                          textColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.sync_alt,
                          label: 'Trade',
                          color: const Color(0xFFFDE68A),
                          textColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.arrow_downward,
                          label: 'Withdraw',
                          color: const Color(0xFF60A5FA),
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Transaction Section
                  const Text(
                    'Transaction',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Transaction Items (lined style, spaced out)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: [
                        _transactionItem(
                          icon: Icons.person,
                          title: 'Matteo',
                          subtitle: 'Aug 25, 2022',
                          amount: '€100',
                        ),
                        _transactionItem(
                          icon: Icons.currency_bitcoin,
                          title: 'Bitcoin',
                          subtitle: 'Aug 25, 2022',
                          amount: '\$300',
                        ),
                        _transactionItem(
                          icon: Icons.account_balance_wallet,
                          title: 'Solana',
                          subtitle: 'Aug 25, 2022',
                          amount: '\$900',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40), // extra breathing space at bottom
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: 85,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white.withValues(alpha: 0.05),
                    highlightColor: Colors.white.withValues(alpha: 0.02),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14.0,
      ), // more breathing space
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white24, thickness: 1, height: 1),
        ],
      ),
    );
  }
}
