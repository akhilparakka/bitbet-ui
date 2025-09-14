import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3dart/web3dart.dart';
import 'user_api_service.dart';

// Login result for type safety
class LoginResult {
  final bool success;
  final String? error;
  final dynamic address; // Using dynamic to match credentials.address type

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

  // User state
  EthPrivateKey? _credentials;
  dynamic _address;
  String? _userEmail;
  String? _userName;

  bool get isLoggedIn => _credentials != null;

  // Main login method (consolidates all login logic)
  Future<LoginResult> loginWithGoogle() async {
    try {
      debugPrint("=== WEB3 CLIENT: Starting Google login ===");

      // Web3Auth login (same as before)
      final res = await Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.google),
      );

      debugPrint("Web3Auth login successful");

      // Extract credentials (same as before)
      final credentials = EthPrivateKey.fromHex(res.privKey!);
      final address = credentials.address;

      // Store in memory
      _credentials = credentials;
      _address = address;
      _userEmail = res.userInfo?.email;
      _userName = res.userInfo?.name;

      // Save to SharedPreferences (same as before)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', res.privKey ?? "");
      await prefs.setString('address', address.toString());
      await prefs.setString('email', _userEmail ?? "");
      await prefs.setString('name', _userName ?? "");
      debugPrint("Credentials saved to SharedPreferences");

      // API call (same as before)
      debugPrint("Calling user API...");
      final userService = UserApiService();
      final apiSuccess = await userService.saveUserData(
        publicKey: address.toString(),
        imageUrl: res.userInfo?.profileImage ?? '',
        address: address.toString(),
      );

      if (apiSuccess) {
        debugPrint("=== WEB3 CLIENT: Login successful ===");
        return LoginResult.success(address);
      } else {
        debugPrint("=== WEB3 CLIENT: API call failed ===");
        return LoginResult.failure("Failed to save user data");
      }

    } catch (e) {
      debugPrint("=== WEB3 CLIENT: Login error: $e ===");
      return LoginResult.failure(e.toString());
    }
  }

  // Getters for UI access
  dynamic get address => _address;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
}