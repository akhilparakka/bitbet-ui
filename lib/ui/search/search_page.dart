import 'package:flutter/material.dart';
import 'package:bitbet/ui/custom_widgets/navigation_sidebar.dart';
import '../common/app_styles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String selectedSection = 'Leagues';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, String>> _navData = [
    {'name': 'Leagues', 'icon': 'assets/svg/games.svg'},
    {'name': 'Sports', 'icon': 'assets/svg/games.svg'},
  ];

  final Map<String, Widget> _sectionWidgets = {
    'Leagues': const Text(
      "Leagues Section\nSearch for leagues",
      style: AppStyles.headerSmall,
      textAlign: TextAlign.center,
    ),
    'Sports': const Text(
      "Sports Section\nSearch for sports",
      style: AppStyles.headerSmall,
      textAlign: TextAlign.center,
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
                        CustomHeader(
                          title: 'Search',
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                        ),
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

  Future<void> _onSectionChanged(String section) async {
    if (selectedSection == section) return;
    setState(() {
      selectedSection = section;
    });
  }
}

class CustomHeader extends StatelessWidget {
  final String title;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;

  const CustomHeader({
    super.key,
    required this.title,
    this.searchController,
    this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(60, 65, 20, 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (searchController != null && searchFocusNode != null)
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                textAlign: TextAlign.right,
                style: AppStyles.headerLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: title,
                  hintStyle: AppStyles.headerLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                cursorColor: Colors.white,
                cursorWidth: 2,
              ),
            )
          else
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
