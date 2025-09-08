import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitbet/ui/home/nav_sections/all_games_section.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedSection = 'All Games';
  late AnimationController _slideController;
  bool _isAnimating = false;
  String? _outgoingSection;
  bool _slideUp = true;

  @override
  void initState() {
    super.initState();
    debugPrint("HomePage initState called");
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController.value = 1.0;
  }

  final List<String> _navOrder = [
    'All Games',
    'Favorites',
    'My Bets',
    'Discover',
    'Leaderboards',
    'Profile',
  ];

  final Map<String, Widget> _sectionWidgets = {
    'All Games': const AllGamesSection(),
    'Favorites': const Text(
      "Favorites Section\nYour favorite games appear here",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
    'My Bets': const Text(
      "My Bets Section\nTrack your betting history and active bets",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
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
    'Profile': const Text(
      "Profile Section\nManage your account and settings",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50), // Dark blue-gray
              Color(0xFF34495E), // Slightly lighter
              Color(0xFF2C3E50), // Back to dark
              Color(0xFF1A252F), // Very dark at bottom
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Row(
                children: [
                  CustomNavigationSidebar(
                    selectedSection: selectedSection,
                    onSectionChanged: _onSectionChanged,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CustomHeader(title: selectedSection),
                        Expanded(
                          child: _buildContentForSection(selectedSection),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 85,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // print('Settings icon pressed!');
                      },
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha: 0.05),
                      highlightColor: Colors.white.withValues(alpha: 0.02),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/svg/settings.svg",
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;

          return Stack(
            children: [
              if (_outgoingSection != null && _isAnimating)
                Transform.translate(
                  offset: _slideUp
                      ? Offset(0, -_slideController.value * screenHeight)
                      : Offset(0, _slideController.value * screenHeight),
                  child: _sectionWidgets[_outgoingSection!],
                ),

              Transform.translate(
                offset: _isAnimating && _outgoingSection != null
                    ? _slideUp
                          ? Offset(
                              0,
                              (1.0 - _slideController.value) * screenHeight,
                            ) // Slide up from bottom
                          : Offset(
                              0,
                              -(1.0 - _slideController.value) * screenHeight,
                            )
                    : Offset.zero,
                child:
                    _sectionWidgets[section] ??
                    Center(
                      child: Text(
                        "Section '$section' not found",
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
              ),
            ],
          );
        },
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
    debugPrint("HomePage dispose called");
    _slideController.dispose();
    super.dispose();
  }
}

class CustomNavigationSidebar extends StatelessWidget {
  final String selectedSection;
  final Function(String) onSectionChanged;

  const CustomNavigationSidebar({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
  });

  static const List<Map<String, String>> _navData = [
    {'name': 'All Games', 'icon': 'assets/svg/games.svg'},
    {'name': 'Favorites', 'icon': 'assets/svg/favorites.svg'},
    {'name': 'My Bets', 'icon': 'assets/svg/ticket.svg'},
    {'name': 'Discover', 'icon': 'assets/svg/discover.svg'},
    {'name': 'Leaderboards', 'icon': 'assets/svg/leaderboard.svg'},
    {'name': 'Profile', 'icon': 'assets/svg/user.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 150),
          Expanded(
            child: ListView(
              children: _navData
                  .map(
                    (item) =>
                        _buildNavItem(item['name']!, item['icon']!, context),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String section, String iconPath, BuildContext context) {
    bool isSelected = selectedSection == section;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.02),
            onTap: () => onSectionChanged(section),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 15,
                      height: 15,
                      transform: Matrix4.translationValues(
                        isSelected ? 0 : -20,
                        0,
                        0,
                      ),
                      child: SvgPicture.asset(
                        iconPath,
                        colorFilter: isSelected
                            ? const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              )
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.srcIn,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          section,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF666666),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(60, 80, 20, 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
