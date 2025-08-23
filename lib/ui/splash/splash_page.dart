import 'dart:async';

import 'package:better/domain/app_colors.dart';
import 'package:better/domain/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
    animate();
  }

  void animate() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      width = 80;
      height = 70;
    });
    await Future.delayed(Duration(milliseconds: 502));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Center(
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
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
