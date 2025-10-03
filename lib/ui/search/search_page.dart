import 'package:flutter/material.dart';
import 'package:bitbet/ui/custom_widgets/navigation_sidebar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String selectedSection = 'Leagues';

  final List<Map<String, String>> _navData = [
    {'name': 'Leagues', 'icon': 'assets/svg/games.svg'},
    {'name': 'Sports', 'icon': 'assets/svg/games.svg'},
  ];

  final Map<String, Widget> _sectionWidgets = {
    'Leagues': const Text(
      "Leagues Section\nSearch for leagues",
      style: TextStyle(color: Colors.white, fontSize: 18),
      textAlign: TextAlign.center,
    ),
    'Sports': const Text(
      "Sports Section\nSearch for sports",
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
              Color(0xFF1F2937), // Darker blue-gray
              Color(0xFF253342), // Darker lighter
              Color(0xFF1F2937), // Back to dark
              Color(0xFF0F1419), // Even darker at bottom
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
                    navData: _navData,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CustomHeader(title: 'Search'),
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
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha: 0.05),
                      highlightColor: Colors.white.withValues(alpha: 0.02),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
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
      child: _sectionWidgets[section] ??
          Center(
            child: Text(
              "Section '$section' not found",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
    );
  }

  Future<void> _onSectionChanged(String section) async {
    if (selectedSection == section) return;
    setState(() {
      selectedSection = section;
    });
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