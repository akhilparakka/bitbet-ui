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
  ];

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 30,
      right: 30,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Main navigation pill
          Expanded(
            child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ),
          const SizedBox(width: 16),
          // Quick action button (search)
          _buildQuickActionButton(),
        ],
      ),
    );
  }

  Widget _buildNavButton(String section, String iconPath, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onSectionChanged(section),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(0.125), // 45 degrees
            child: Icon(Icons.search, color: const Color(0xFF888888), size: 26),
          ),
        ),
      ),
    );
  }
}
