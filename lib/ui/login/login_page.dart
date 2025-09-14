import 'package:bitbet/domain/app_colors.dart';
import 'package:bitbet/domain/ui_heloper.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'package:bitbet/ui/custom_widgets/oblong_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Log existing address if available (keep for debugging)
    final prefs = await SharedPreferences.getInstance();
    String? existingAddress = prefs.getString('address');
    if (existingAddress != null && existingAddress.isNotEmpty) {
      debugPrint("Existing user address: $existingAddress");
    }

    debugPrint("Starting login via Web3BetClient...");

    // Use centralized client
    final web3Client = Web3BetClient();
    final result = await web3Client.loginWithGoogle();

    setState(() {
      isGoogleLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      debugPrint("Login successful, navigating to home...");
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      debugPrint("Navigation completed.");
    } else {
      // Show error dialog (same as before)
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(result.error ?? 'Login failed. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
                  Color(0xFF1F2937), // Darker blue-gray
                  Color(0xFF253342), // Darker lighter
                  Color(0xFF1F2937), // Back to dark
                  Color(0xFF0F1419), // Even darker at bottom
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
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
