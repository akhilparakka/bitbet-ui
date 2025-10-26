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
    {'name': 'All Games', 'icon': 'assets/svg/games.svg'},
    {'name': 'My Bets', 'icon': 'assets/svg/ticket.svg'},
    {'name': 'Favorites', 'icon': 'assets/svg/favorites.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main navigation pill
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: navItems.map((item) {
                  final isSelected = widget.selectedSection == item['name'];
                  return _buildNavButton(
                    item['name']!,
                    item['icon']!,
                    isSelected,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            // Quick action button (search)
            _buildQuickActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String section, String iconPath, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onSectionChanged(section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D2D2D) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : const Color(0xFF666666),
                BlendMode.srcIn,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(section),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return GestureDetector(
      onTap: widget.onQuickActionTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.search, color: const Color(0xFF888888), size: 26),
        ),
      ),
    );
  }
}
