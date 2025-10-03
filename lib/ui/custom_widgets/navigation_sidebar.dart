import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitbet/ui/profile/profile_page.dart';

class CustomNavigationSidebar extends StatelessWidget {
  final String selectedSection;
  final Function(String) onSectionChanged;
  final List<Map<String, String>> navData;

  const CustomNavigationSidebar({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
    this.navData = const [
      {'name': 'All Games', 'icon': 'assets/svg/games.svg'},
      {'name': 'Favorites', 'icon': 'assets/svg/favorites.svg'},
      {'name': 'My Bets', 'icon': 'assets/svg/ticket.svg'},
      {'name': 'Discover', 'icon': 'assets/svg/discover.svg'},
      {'name': 'Leaderboards', 'icon': 'assets/svg/leaderboard.svg'},
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 135),
          Expanded(
            child: ListView(
              children: navData
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
            onTap: () {
              if (section == 'Profile') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              } else {
                onSectionChanged(section);
              }
            },
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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