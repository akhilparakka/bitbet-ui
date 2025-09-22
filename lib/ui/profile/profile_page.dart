import 'package:flutter/material.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'package:web3dart/web3dart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  EtherAmount? _balance;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final balance = await Web3BetClient().getBalance();
      setState(() {
        _balance = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // base background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top Green Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),

                     // Balance
                     Center(
                       child: Column(
                         children: [
                           const Icon(
                             Icons.account_balance_wallet,
                             color: Colors.black,
                             size: 40,
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             "Pocket",
                             style: TextStyle(
                               fontSize: 16,
                               color: Colors.black87,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                           const SizedBox(height: 8),
                             SizedBox(
                               height: 45,
                               child: Center(
                                 child: _isLoading
                                     ? Container(
                                         width: 200,
                                         height: 45,
                                         decoration: BoxDecoration(
                                           color: const Color.fromRGBO(0, 0, 0, 0.1),
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                       )
                                     : _error != null
                                         ? Text(
                                             "Error: $_error",
                                             style: const TextStyle(
                                               fontSize: 16,
                                               color: Colors.red,
                                             ),
                                           )
                                         : Text(
                                             _balance != null
                                                 ? "${_balance!.getValueInUnit(EtherUnit.ether).toStringAsFixed(4)} ETH"
                                                 : "0.0000 ETH",
                                             style: const TextStyle(
                                               fontSize: 34,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.black,
                                             ),
                                           ),
                               ),
                             ),
                         ],
                       ),
                     ),

                    const SizedBox(height: 20),

                    // Deposit / Withdraw Buttons inside green box
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Deposit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Withdraw",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
