import 'package:bitbet/ui/home/nav_sections/all_games_section.dart';
import 'package:bitbet/ui/home/nav_sections/favorites_section.dart';
import 'package:bitbet/ui/home/nav_sections/leaderboard_section.dart';
import 'package:bitbet/ui/home/nav_sections/my_bets_section.dart';
import 'package:bitbet/ui/custom_widgets/floating_navigation.dart';
import 'package:bitbet/ui/profile/profile_page.dart';
import 'package:bitbet/ui/search/search_page.dart';
import 'package:bitbet/ui/common/app_styles.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String selectedSection = 'Home';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Web3BetClient().loadUserData();
      if (mounted) setState(() {});
    });
  }

  final Map<String, Widget> _sectionWidgets = {
    'Home': const AllGamesSection(),
    'Favorites': const FavoritesSection(),
    'My Bets': const MyBetsSection(),
    'Top': const LeaderboardSection(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Container(
        color: const Color(0xFF0F1419),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Main content area - now takes full width
              Column(
                children: [
                  CustomHeader(title: selectedSection),
                  Expanded(child: _buildContentForSection(selectedSection)),
                ],
              ),

              // Profile button (top-left)
              Positioned(
                top: 70,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha: 0.05),
                      highlightColor: Colors.white.withValues(alpha: 0.02),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: Web3BetClient().profileImage != null
                            ? NetworkImage(Web3BetClient().profileImage!)
                            : null,
                        child: Web3BetClient().profileImage == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              // New floating navigation
              FloatingNavigation(
                selectedSection: selectedSection,
                onSectionChanged: _onSectionChanged,
                onQuickActionTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SearchPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentForSection(String section) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(section),
            child: _sectionWidgets[section] ??
                Center(
                  child: Text(
                    "Section '$section' not found",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSectionChanged(String section) async {
    if (selectedSection == section) return;

    if (section == 'Search') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SearchPage(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
      return;
    }

    setState(() {
      selectedSection = section;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(20, 65, 20, 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: AppStyles.headerLarge.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }
}
