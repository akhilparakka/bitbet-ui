import 'package:bitbet/domain/app_colors.dart';
import 'package:bitbet/domain/ui_heloper.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/ui/custom_widgets/oblong_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
  }



  Future<void> _loginGoogle() async {
    setState(() {
      isGoogleLoading = true;
    });
    debugPrint("Starting Google login...");
    try {
      final res = await Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.google),
      );

      // await Web3AuthFlutter.getPrivKey();
      debugPrint("Login successful!");
      debugPrint("User Info: ${res.userInfo}");
      debugPrint("Email: ${res.userInfo?.email}");
      debugPrint("Name: ${res.userInfo?.name}");
      debugPrint("Private Key: ${res.privKey}");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', res.privKey ?? "");
      setState(() {
        isGoogleLoading = false;
      });
      if (!mounted) return;
      debugPrint("Navigating to home...");
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      debugPrint("Navigation completed.");
    } catch (e) {
      debugPrint("Google login error: $e");
      setState(() {
        isGoogleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          Image.asset("assets/images/poster.png"),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blackColor.withValues(alpha: 0.3),
                  AppColors.blackColor,
                ],
              ),
            ),
          ),
          bottomloginUI(),
        ],
      ),
    );
  }

  Widget bottomloginUI() => Container(
    padding: const EdgeInsets.only(bottom: 50),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/games.svg",
          width: 50,
          height: 50,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        msPacer(),
        const Text(
          "bitbet odds. \nSmarter betting.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        msPacer(),
        msPacer(),
        msPacer(),
        // Google Login Button
        OblongButton(
          mIconPath: "assets/Logo/google-icon.svg",
          text: "Continue with Google",
          bgColor: const Color(0xFF1F1F1F),
          textColor: Colors.white,
          borderColor: const Color(0xFF3C4043),
          mWidth: 280,
          mHeight: 48,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          iconSize: 18,
          isLoading: isGoogleLoading,
          onTap: _loginGoogle,
        ),
        msPacer(),
        // GitHub Login Button
        OblongButton(
          text: "Continue with GitHub",
          bgColor: const Color(0xFF1F1F1F),
          textColor: Colors.white,
          borderColor: const Color(0xFF3C4043),
          mWidth: 280,
          mHeight: 48,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          onTap: () => {},
        ),
        msPacer(),
        TextButton(
          onPressed: () {
            debugPrint('Manual login tapped');
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}
