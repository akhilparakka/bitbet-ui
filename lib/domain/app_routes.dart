import 'package:bitbet/ui/follow_league/follow_league_page.dart';
import 'package:bitbet/ui/follow_team/follow_team_page.dart';
import 'package:bitbet/ui/home/home.dart';
import 'package:bitbet/ui/login/login_page.dart';
import 'package:bitbet/ui/onboarding/onboarding_page.dart';
import 'package:bitbet/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String followLeague = '/follow-league';
  static const String followTeam = '/follow-team';
  static const String home = '/home';
  static const String gameDetails = '/game-details';

  static Map<String, Widget Function(BuildContext)> getRoutes() => {
    splash: (context) => const SplashPage(),
    onboarding: (context) => const OnboardingPage(),
    login: (context) => const LoginPage(),
    followLeague: (context) => const FollowLeaguePage(),
    followTeam: (context) => const FollowTeamPage(),
    home: (context) => const HomePage(),
    // gameDetails route removed - using direct navigation instead
  };
}
