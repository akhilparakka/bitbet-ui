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
  String? _profileImage;

  bool get isLoggedIn => _credentials != null;

  // Main login method (consolidates all login logic)
  Future<LoginResult> loginWithGoogle() async {
    try {
      debugPrint("=== WEB3 CLIENT: Starting Google login ===");

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

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _address = prefs.getString('address');
    _userEmail = prefs.getString('email');
    _userName = prefs.getString('name');
    _profileImage = prefs.getString('profileImage');
    final privateKey = prefs.getString('privateKey');
    if (privateKey != null && privateKey.isNotEmpty) {
      _credentials = EthPrivateKey.fromHex(privateKey);
    }
  }

  dynamic get address => _address;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get profileImage => _profileImage;
}
