import 'dart:async';
import 'dart:io';
import 'package:bitbet/domain/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    animate();
  }

  void animate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    await _initWeb3Auth();

    final prefs = await SharedPreferences.getInstance();
    String? privKey = prefs.getString('privateKey');
    String route = (privKey != null && privKey.isNotEmpty)
        ? AppRoutes.home
        : AppRoutes.login;

    // Log address if user is already logged in
    if (privKey != null && privKey.isNotEmpty) {
      String? address = prefs.getString('address');
      if (address != null && address.isNotEmpty) {
        debugPrint("=== SPLASH: USER ALREADY LOGGED IN ===");
        debugPrint("Address: $address");
        debugPrint("PrivateKey length: ${privKey.length}");
        debugPrint("Note: User exists in SharedPreferences but may not exist in backend");
        debugPrint("=== SPLASH: PROCEEDING TO HOME ===");
      } else {
        debugPrint("=== SPLASH: INVALID LOGIN STATE ===");
        debugPrint("PrivateKey exists but address is null/empty");
      }
    } else {
      debugPrint("=== SPLASH: NO LOGIN SESSION ===");
      debugPrint("Proceeding to login page");
    }

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }

  Future<void> _initWeb3Auth() async {
    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.example.bitbet');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.example.bitbet://auth');
    } else {
      throw Exception('Unsupported platform');
    }

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId:
            "BDFPlNSKK8hPNsO8zyFCp59ll1SUrEq9oaXCzHTAXNA1RifyvsnrXWthdSpug_HDq619GOAv_OwsqXKRB-MnhEQ",
        network: Network.sapphire_devnet,
        redirectUrl: redirectUrl,
      ),
    );

    try {
      await Web3AuthFlutter.initialize();
    } catch (e) {
      // Ignore "No user found" error as it's expected when no session exists
      if (!e.toString().contains('No user found')) {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F2937), // Darker blue-gray
              Color(0xFF253342), // Darker lighter
              Color(0xFF1F2937), // Back to dark
              Color(0xFF0F1419), // Even darker at bottom
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Image.asset(
            "assets/Logo/bitbet-logo.png",
            width: 250,
            height: 218,
          ),
        ),
      ),
    );
  }
}
