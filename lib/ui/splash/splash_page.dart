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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF415CC0), // Blue from Figma
              Color(0xFF2BBEBD), // Cyan/turquoise from Figma
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circle/ellipse background
            Positioned(
              left: 51,
              top: 243,
              child: Container(
                width: 597,
                height: 597,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Logo centered
            Center(
              child: Image.asset(
                "assets/Logo/bidibet-logo.png",
                width: 229,
                height: 331,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
