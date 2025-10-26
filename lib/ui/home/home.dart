import 'package:bitbet/ui/home/nav_sections/all_games_section.dart';
import 'package:bitbet/ui/home/nav_sections/favorites_section.dart';
import 'package:bitbet/ui/home/nav_sections/my_bets_section.dart';
import 'package:bitbet/ui/custom_widgets/floating_navigation.dart';
import 'package:bitbet/ui/profile/profile_page.dart';
import 'package:bitbet/ui/search/search_page.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedSection = 'Home';
  late AnimationController _slideController;
  bool _isAnimating = false;
  String? _outgoingSection;
  bool _slideUp = true;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Web3BetClient().loadUserData();
      if (mounted) setState(() {});
    });
  }

  final List<String> _navOrder = [
    'Home',
    'Favorites',
    'My Bets',
    'Discover',
    'Leaderboards',
  ];

  final Map<String, Widget> _sectionWidgets = {
    'Home': const AllGamesSection(),
    'Favorites': const FavoritesSection(),
    'My Bets': const MyBetsSection(),
    'Discover': const Text(
      "Discover Section\nFind new and trending games",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
    'Leaderboards': const Text(
      "Leaderboards Section\nSee top players and rankings",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
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
        child: AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
            );

            return Stack(
              children: [
                if (_outgoingSection != null && _isAnimating)
                  Opacity(
                    opacity: 1.0 - _slideController.value,
                    child: _sectionWidgets[_outgoingSection!],
                  ),

                ScaleTransition(
                  scale: _isAnimating && _outgoingSection != null ? scaleAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Opacity(
                    opacity: _isAnimating && _outgoingSection != null
                        ? _slideController.value
                        : 1.0,
                    child: _sectionWidgets[section] ??
                        Center(
                          child: Text(
                            "Section '$section' not found",
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onSectionChanged(String section) async {
    if (_isAnimating || selectedSection == section) return;

    final currentIndex = _navOrder.indexOf(selectedSection);
    final newIndex = _navOrder.indexOf(section);
    _slideUp = newIndex > currentIndex;

    setState(() {
      _isAnimating = true;
      _outgoingSection = selectedSection;
      selectedSection = section;
    });

    _slideController.value = 0.0;
    await _slideController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      _isAnimating = false;
      _outgoingSection = null;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
