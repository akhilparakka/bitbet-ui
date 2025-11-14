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

    // Check if user has seen onboarding
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Determine navigation route
    String route;
    if (!hasSeenOnboarding) {
      // First-time user - show onboarding
      route = AppRoutes.onboarding;
    } else {
      // Returning user - check if logged in
      String? privKey = prefs.getString('privateKey');
      route = (privKey != null && privKey.isNotEmpty)
          ? AppRoutes.home
          : AppRoutes.login;
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
      backgroundColor: const Color(0xFFFF2882), // Vibrant pink from Figma
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container with semi-transparent background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.scoreboard_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // App name text
            const Text(
              'ScoreBoard',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.09,
                height: 26 / 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
