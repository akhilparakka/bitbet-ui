import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitbet/domain/app_routes.dart';

void main() async {
  await dotenv.load();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
