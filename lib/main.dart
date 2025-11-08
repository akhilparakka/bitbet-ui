import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/core/config/app_config.dart';
import 'package:bitbet/domain/services/betting_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Validate configuration
  AppConfig.validateConfig();

  // Initialize ABI cache for faster betting transactions
  await BettingService.initializeAbis();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAssets();
  }

  void _precacheAssets() {
    // Precache SVG icons for faster navigation
    final svgAssets = [
      'assets/svg/home.svg',
      'assets/svg/favorites.svg',
      'assets/svg/ticket.svg',
      'assets/svg/leaderboard.svg',
      'assets/svg/discover.svg',
      'assets/svg/games.svg',
    ];

    // Load SVGs into cache
    for (final asset in svgAssets) {
      svg.cache.putIfAbsent(
        asset,
        () => SvgAssetLoader(asset).loadBytes(context),
      );
    }

    // Precache app logo only (league logos come from API)
    precacheImage(const AssetImage('assets/Logo/bitbet-logo.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BitBet - Sports Betting',
      theme: ThemeData(
        fontFamily: "montserrat",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.splash,
    );
  }
}
