import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingNavigation extends StatefulWidget {
  final String selectedSection;
  final Function(String) onSectionChanged;
  final VoidCallback onQuickActionTap;

  const FloatingNavigation({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.onQuickActionTap,
  });

  @override
  State<FloatingNavigation> createState() => _FloatingNavigationState();
}

class _FloatingNavigationState extends State<FloatingNavigation> {
  final List<Map<String, String>> navItems = [
    {'name': 'Home', 'icon': 'assets/svg/home.svg'},
    {'name': 'Favorites', 'icon': 'assets/svg/favorites.svg'},
    {'name': 'My Bets', 'icon': 'assets/svg/ticket.svg'},
    {'name': 'Discover', 'icon': 'assets/svg/discover.svg'},
    {'name': 'Profile', 'icon': 'assets/svg/user.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navItems.indexWhere(
      (item) => item['name'] == widget.selectedSection,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1D1F24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Blue indicator bar at top
            Container(
              height: 2,
              width: double.infinity,
              child: selectedIndex >= 0
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / navItems.length;
                        final indicatorLeft = (itemWidth * selectedIndex) + (itemWidth - 56) / 2;

                        return Stack(
                          children: [
                            Positioned(
                              left: indicatorLeft,
                              child: Container(
                                width: 56,
                                height: 2,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF539DF3),
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            // Navigation items
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: navItems.map((item) {
                  final isSelected = widget.selectedSection == item['name'];
                  return Expanded(
                    child: _buildNavButton(
                      item['name']!,
                      item['icon']!,
                      isSelected,
                    ),
                  );
                }).toList(),
              ),
            ),
            // Safe area for bottom notch
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String section, String iconPath, bool isSelected) {
    return InkWell(
      onTap: () {
        widget.onSectionChanged(section);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF539DF3) : const Color(0xFF676D75),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              section,
              style: TextStyle(
                color: isSelected ? const Color(0xFF539DF3) : const Color(0xFF676D75),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
