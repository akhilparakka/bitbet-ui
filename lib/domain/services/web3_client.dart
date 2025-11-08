import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'user_api_service.dart';
import 'betting_service.dart';

// Login result for type safety
class LoginResult {
  final bool success;
  final String? error;
  final dynamic address;

  const LoginResult._({required this.success, this.error, this.address});

  factory LoginResult.success(dynamic address) =>
      LoginResult._(success: true, address: address);

  factory LoginResult.failure(String error) =>
      LoginResult._(success: false, error: error);
}

class Web3BetClient {
  static final Web3BetClient _instance = Web3BetClient._internal();
  factory Web3BetClient() => _instance;
  Web3BetClient._internal();

  EthPrivateKey? _credentials;
  dynamic _address;
  String? _userEmail;
  String? _userName;
  String? _profileImage;
  String? _dominantColorHex;

  bool get isLoggedIn => _credentials != null;

  Future<LoginResult> loginWithGoogle() async {
    try {
      final res = await Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.google),
      );

      final credentials = EthPrivateKey.fromHex(res.privKey!);
      final address = credentials.address;

      _credentials = credentials;
      _address = address;
      _userEmail = res.userInfo?.email;
      _userName = res.userInfo?.name;
      _profileImage = res.userInfo?.profileImage;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', res.privKey ?? "");
      await prefs.setString('address', address.toString());
      await prefs.setString('email', _userEmail ?? "");
      await prefs.setString('name', _userName ?? "");
      await prefs.setString('profileImage', _profileImage ?? "");

      debugPrint('=== LOGIN: Saving user to database ===');
      debugPrint('Address: ${address.toString()}');
      debugPrint('Image URL: ${res.userInfo?.profileImage ?? ''}');

      final userService = UserApiService();
      final apiSuccess = await userService.saveUserData(
        publicKey: address.toString(),
        imageUrl: res.userInfo?.profileImage ?? '',
        address: address.toString(),
      );

      debugPrint('=== LOGIN: API Save Result: $apiSuccess ===');

      if (apiSuccess) {
        debugPrint('=== LOGIN: User successfully saved to database ===');
        return LoginResult.success(address);
      } else {
        debugPrint('=== LOGIN ERROR: Failed to save user data to database ===');
        return LoginResult.failure("Failed to save user data");
      }
    } catch (e) {
      return LoginResult.failure(e.toString());
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _address = prefs.getString('address');
    _userEmail = prefs.getString('email');
    _userName = prefs.getString('name');
    _profileImage = prefs.getString('profileImage');
    _dominantColorHex = prefs.getString('dominantColor');
    final privateKey = prefs.getString('privateKey');
    if (privateKey != null && privateKey.isNotEmpty) {
      _credentials = EthPrivateKey.fromHex(privateKey);
    }
  }

  Future<Color?> getDominantColor() async {
    // Return cached dominant color if available
    if (_dominantColorHex != null) {
      return Color(int.parse(_dominantColorHex!, radix: 16));
    }

    // Return a default color based on user info
    // This is much faster and doesn't require image processing
    if (_userEmail != null && _userEmail!.isNotEmpty) {
      // Generate a consistent color from email hash
      final hash = _userEmail!.hashCode.abs();
      final hue = (hash % 360).toDouble();
      final color = HSVColor.fromAHSV(1.0, hue, 0.6, 0.7).toColor();
      _dominantColorHex = color.toARGB32().toRadixString(16).padLeft(8, '0');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dominantColor', _dominantColorHex!);
      return color;
    }

    return Colors.blueGrey;
  }

  Future<EtherAmount> getBalance() async {
    if (_credentials == null || _address == null) {
      throw Exception('User not logged in');
    }

    try {
      final client = Web3Client(
        'https://eth-sepolia.g.alchemy.com/v2/xuu9ST6cfCwJ-pgZpykfVDsYLhW9pT6k',
        Client(),
      );
      final address = EthereumAddress.fromHex(_address!);
      final balance = await client.getBalance(address);
      return balance;
    } catch (e) {
      return EtherAmount.inWei(BigInt.zero);
    }
  }

  /// Get USDT balance (returns human-readable value)
  Future<double> getUsdtBalance(String usdtContractAddress) async {
    if (_credentials == null || _address == null) {
      throw Exception('User not logged in');
    }

    try {
      final rpcUrl = dotenv.env['RPC_URL'] ?? 'http://localhost:8545';
      final client = Web3Client(rpcUrl, Client());
      final userAddress = EthereumAddress.fromHex(_address!);
      final tokenAddress = EthereumAddress.fromHex(usdtContractAddress);

      // Simple ERC20 ABI for balanceOf and decimals
      final contract = DeployedContract(
        ContractAbi.fromJson(
          '[{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"}]',
          'ERC20',
        ),
        tokenAddress,
      );

      // Get decimals
      final decimalsFunction = contract.function('decimals');
      final decimalsResult = await client.call(
        contract: contract,
        function: decimalsFunction,
        params: [],
      );
      final decimals = (decimalsResult.first as BigInt).toInt();

      // Get balance
      final balanceFunction = contract.function('balanceOf');
      final balanceResult = await client.call(
        contract: contract,
        function: balanceFunction,
        params: [userAddress],
      );
      final balance = balanceResult.first as BigInt;

      // Convert to human-readable format
      return balance.toDouble() / pow(10, decimals);
    } catch (e) {
      debugPrint('Error getting USDT balance: $e');
      return 0.0;
    }
  }

  /// Get BettingService instance
  BettingService? getBettingService() {
    if (_credentials == null) {
      return null;
    }

    final rpcUrl =
        dotenv.env['RPC_URL'] ??
        'https://eth-sepolia.g.alchemy.com/v2/xuu9ST6cfCwJ-pgZpykfVDsYLhW9pT6k';
    final client = Web3Client(rpcUrl, Client());

    return BettingService(web3Client: client, credentials: _credentials!);
  }

  dynamic get address => _address;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get profileImage => _profileImage;
  bool get hasCachedColor => _dominantColorHex != null;
}
