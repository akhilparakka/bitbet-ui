import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitbet/ui/home/nav_sections/all_games_section.dart';
import 'package:bitbet/ui/home/nav_sections/favorites_section.dart';
import 'package:bitbet/ui/profile/profile_page.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedSection = 'All Games';
  late AnimationController _slideController;
  late AnimationController _colorAnimationController;
  bool _isAnimating = false;
  String? _outgoingSection;
  bool _slideUp = true;
  Color? _dominantColor;
  bool _colorLoaded = false;
  double _colorAnimationValue = 0.0;

  static const List<Color> _defaultColors = [
    Color(0xFF1F2937), // Darker blue-gray
    Color(0xFF253342), // Darker lighter
    Color(0xFF1F2937), // Back to dark
    Color(0xFF0F1419), // Even darker at bottom
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController.value = 1.0;

    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _colorAnimationController.addListener(() {
      setState(() {
        _colorAnimationValue = _colorAnimationController.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Web3BetClient().loadUserData();
      if (mounted) setState(() {});
      await _loadDominantColor();
    });
  }

  Future<void> _loadDominantColor() async {
    final client = Web3BetClient();
    final wasCached = client.hasCachedColor;
    final color = await client.getDominantColor();
    setState(() {
      _dominantColor = color ?? Colors.blueGrey;
      _colorLoaded = true;
    });
    if (!wasCached) {
      _colorAnimationController.forward(from: 0.0);
    } else {
      _colorAnimationController.value = 1.0;
    }
  }

  final List<String> _navOrder = [
    'All Games',
    'Favorites',
    'My Bets',
    'Discover',
    'Leaderboards',
  ];

  final Map<String, Widget> _sectionWidgets = {
    'All Games': const AllGamesSection(),
    'Favorites': const FavoritesSection(),
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
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: _colorLoaded && _dominantColor != null
              ? RadialGradient(
                  center: const Alignment(
                    -0.8,
                    -0.8,
                  ), // Approximate position of profile icon
                  radius: _colorAnimationValue * 3.0,
                  colors: [
                    _dominantColor!.withValues(alpha: 0.4),
                    _dominantColor!.withValues(alpha: 0.3),
                    _dominantColor!.withValues(alpha: 0.2),
                    _dominantColor!.withValues(alpha: 0.1),
                    _dominantColor!.withValues(alpha: 0.05),
                  ],
                  stops: [0.0, 0.2, 0.4, 0.6, 0.8],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _defaultColors,
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
                 top: 70,
                 left: 20,
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(22),
                   child: Material(
                     color: Colors.transparent,
                     child: InkWell(
                       onTap: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(
                             builder: (_) => const ProfilePage(),
                           ),
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
               Positioned(
                 bottom: 40,
                 right: 20,
                 child: Container(
                   width: 70,
                   height: 70,
                   decoration: BoxDecoration(
                     color: const Color(0xFF00BCD4),
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: IconButton(
                     icon: const Icon(
                       Icons.search,
                       color: Colors.white,
                       size: 32,
                     ),
                     onPressed: () {
                       // TODO: Implement search functionality
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Search not implemented yet')),
                       );
                     },
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
    _slideController.dispose();
    _colorAnimationController.dispose();
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
  ];

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

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(60, 65, 20, 20),
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
