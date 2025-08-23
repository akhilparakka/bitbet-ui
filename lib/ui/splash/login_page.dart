import 'package:better/domain/app_colors.dart';
import 'package:better/domain/ui_heloper.dart';
import 'package:flutter/material.dart';
import "package:better/ui/custom_widgets/oblong_button.dart";
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  AppColors.blackColor.withOpacity(0.3),
                  AppColors.blackColor,
                ],
              ),
            ),
          ),
          bottomloginUI(),
        ],

        // child:
      ),
    );
  }

  Widget bottomloginUI() => Container(
    padding: EdgeInsets.only(bottom: 50),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/Logo/spotify-white-icon.svg",
          width: 50,
          height: 50,
        ),
        msPacer(),
        Text(
          "Millions of songs. \nFree on Spotify.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        msPacer(),
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
          onTap: () {},
        ),
        msPacer(),
        OblongButton(
          mIconPath: "assets/Logo/google-icon.svg",
          text: "Continue with Wallet",
          bgColor: const Color(0xFF1F1F1F),
          textColor: Colors.white,
          borderColor: const Color(0xFF3C4043),
          mWidth: 280,
          mHeight: 48,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          iconSize: 18,
          onTap: () {},
        ),
        TextButton(
          onPressed: () {},
          child: Text(
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
