import 'package:better/ui/splash/login_page.dart';
import 'package:better/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';

  static Map<String, Widget Function(BuildContext)> getRoutes() => {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
  };
}
