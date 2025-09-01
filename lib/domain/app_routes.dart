import 'package:better/ui/home/home.dart';
import 'package:better/ui/login/login_page.dart';
import 'package:better/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String gameDetails = '/game-details';

  static Map<String, Widget Function(BuildContext)> getRoutes() => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    // gameDetails route removed - using direct navigation instead
  };
}
