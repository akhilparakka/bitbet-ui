import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:better/domain/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedSection = 'Appearance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBlackColor,
      body: Material(
        // Ensure Material context for inkwell
        color: AppColors.secondaryBlackColor,
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
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: _buildContentForSection(selectedSection),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 93,
              left: 33,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    print('Settings icon pressed!');
                  },
                  customBorder: CircleBorder(),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlackColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/svg/settings.svg",
                        width: 25,
                        height: 25,
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
    return Container();
  }
}

class CustomNavigationSidebar extends StatelessWidget {
  final String selectedSection;
  final Function(String) onSectionChanged;

  const CustomNavigationSidebar({
    Key? key,
    required this.selectedSection,
    required this.onSectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: AppColors.secondaryBlackColor,
      child: Column(
        children: [
          SizedBox(height: 150),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem('Appearance', context),
                _buildNavItem('Player', context),
                _buildNavItem('Quick picks', context),
                _buildNavItem('Discover', context),
                _buildNavItem('Bettings', context),
                _buildNavItem('Library', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String section, BuildContext context) {
    bool isSelected = selectedSection == section;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSectionChanged(section),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isSelected ? 20 : 0,
                    height: 15,
                    child: isSelected
                        ? SvgPicture.asset(
                            "assets/svg/settings.svg",
                            width: 20,
                            height: 20,
                          )
                        : null,
                  ),
                  SizedBox(width: 0),
                  Expanded(
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          section,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Color(0xFF666666),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
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

  const CustomHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.fromLTRB(60, 80, 20, 20),
      decoration: BoxDecoration(color: AppColors.secondaryBlackColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
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
