import 'dart:async';
import 'dart:io';
import 'package:bitbet/domain/app_colors.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  double width = 10;
  double height = 10;

  @override
  void initState() {
    super.initState();
    animate();
  }

  void animate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        width = 80;
        height = 70;
      });
    }

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

    await Web3AuthFlutter.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: width,
          height: height,
          child: SvgPicture.asset(
            "assets/Logo/spotify-icon.svg",
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}
