import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/domain/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < OnboardingModel.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // PageView for slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingModel.slides.length,
                itemBuilder: (context, index) {
                  final slide = OnboardingModel.slides[index];
                  return _OnboardingSlide(
                    title: slide.title,
                    description: slide.description,
                    imagePath: slide.imagePath,
                    floaterPath: slide.floaterPath,
                  );
                },
              ),
            ),

            // Bottom content section
            Container(
              color: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Title and description
                  _OnboardingContent(
                    slide: OnboardingModel.slides[_currentPage],
                  ),

                  const SizedBox(height: 32),

                  // Dot indicators
                  _DotIndicators(
                    currentPage: _currentPage,
                    totalPages: OnboardingModel.slides.length,
                  ),

                  const SizedBox(height: 48),

                  // Next/Get Started button
                  _NextButton(
                    isLastPage: _currentPage == OnboardingModel.slides.length - 1,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Slide widget showing the layered images (phone mockup + floating card)
class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String floaterPath;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.floaterPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Phone mockup - zoomed out a bit, positioned to the right, partially visible from right and bottom
        Positioned(
          right: -10, // Move back to the right (was 20)
          top: 120,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: screenHeight * 0.6, // Zoom out - from 0.7 to 0.6
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: screenHeight * 0.6,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone_iphone,
                    size: 100,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              );
            },
          ),
        ),

        // Floating score card - pushed down and made a lot bigger, moved left
        Positioned(
          left: 40, // Move to the left (was 60)
          top: 180,
          child: Image.asset(
            floaterPath, // Use dynamic floater path for each slide
            width: screenWidth * 0.7, // Reduced size from 0.85 to 0.7
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Show nothing if floater image not found
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// Content section with title and description
class _OnboardingContent extends StatelessWidget {
  final OnboardingModel slide;

  const _OnboardingContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.12,
            height: 32 / 24,
          ),
        ),

        const SizedBox(height: 12),

        // Description
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E8E93),
            letterSpacing: 0.07,
            height: 22 / 14,
          ),
        ),
      ],
    );
  }
}

// Dot indicators
class _DotIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _DotIndicators({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage
                ? const Color(0xFFFF2882)
                : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }
}

// Next/Get Started button
class _NextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const _NextButton({
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF2882),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isLastPage ? 'Get Started' : 'Next',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.07,
            height: 22 / 14,
          ),
        ),
      ),
    );
  }
}
