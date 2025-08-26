import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better/domain/app_colors.dart';
import 'package:better/ui/home/sections/all_games_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedSection = 'All Games';

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
                  onSectionChanged: (section) {
                    setState(() {
                      selectedSection = section;
                    });
                  },
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    print('Settings icon pressed!');
                  },
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withValues(alpha: .3),
                  highlightColor: Colors.white.withValues(alpha: .1),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFF181818,
                      ), // Matte black for Settings Button
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/svg/settings.svg",
                        width: 20,
                        height: 20,
                        color: Colors.white, // Ensure icon is visible
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      child:
          _sectionWidgets[section] ??
          Center(
            child: Text(
              "Section '$section' not found",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
    );
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
      color: const Color(0xFF181818), // Matte black for Sidebar
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
                      left: 4,
                    ), // Minimal spacing from left edge
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: SvgPicture.asset(iconPath, color: Colors.white),
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
      decoration: const BoxDecoration(
        color: Color(0xFF181818), // Matte black for Header
      ),
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
