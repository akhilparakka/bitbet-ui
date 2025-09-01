import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better/ui/home/sections/all_games_section.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedSection = 'All Games';
  late AnimationController _slideController;
  late Animation<Offset> _outAnimation;
  late Animation<Offset> _inAnimation;
  bool _isAnimating = false;
  String? _outgoingSection;
  bool _slideUp =
      true; // true = slide up (new from bottom), false = slide down (new from top)

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animation for outgoing content (slides up and disappears)
    _outAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    // Animation for incoming content (slides up from bottom)
    _inAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    // Start with content visible
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
      backgroundColor: const Color(0xFF181818), // Matte black for Scaffold
      body: Material(
        color: const Color(0xFF181818), // Match Scaffold background
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
                      Expanded(child: _buildContentForSection(selectedSection)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 85,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  22,
                ), // Half of 44 for perfect circle
                child: Material(
                  color: const Color(0xFF181818),
                  child: InkWell(
                    onTap: () {
                      print('Settings icon pressed!');
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
                          color: Colors.white,
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
              // Outgoing section
              if (_outgoingSection != null && _isAnimating)
                Transform.translate(
                  offset: _slideUp
                      ? Offset(
                          0,
                          -_slideController.value * screenHeight,
                        ) // Slide up and out
                      : Offset(
                          0,
                          _slideController.value * screenHeight,
                        ), // Slide down and out
                  child: _sectionWidgets[_outgoingSection!],
                ),

              // Incoming section
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
                            ) // Slide down from top
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

    // Determine animation direction based on navigation order
    final currentIndex = _navOrder.indexOf(selectedSection);
    final newIndex = _navOrder.indexOf(section);
    _slideUp =
        newIndex >
        currentIndex; // true = slide up (new from bottom), false = slide down (new from top)

    setState(() {
      _isAnimating = true;
      _outgoingSection = selectedSection;
      selectedSection = section;
    });

    // Reset animation to start
    _slideController.value = 0.0;

    // Animate both outgoing and incoming content simultaneously
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
      color: const Color(0xFF181818),
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
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Minimal vertical margin
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.02),
            onTap: () => onSectionChanged(section),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 4,
              ), // Reduced padding
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center, // Center content
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ), // Spacing from left edge
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 15,
                      height: 15,
                      transform: Matrix4.translationValues(
                        isSelected
                            ? 0
                            : -20, // Slide from left (-20px) to position (0)
                        0,
                        0,
                      ),
                      child: SvgPicture.asset(
                        iconPath,
                        color: isSelected ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ), // Minimal spacing between icon and label
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
                            fontSize:
                                12, // Slightly smaller font for better fit
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
      decoration: const BoxDecoration(color: Color(0xFF181818)),
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
