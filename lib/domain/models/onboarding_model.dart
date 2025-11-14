class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final String floaterPath;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.floaterPath,
  });

  // Static list of onboarding slides
  static const List<OnboardingModel> slides = [
    OnboardingModel(
      title: 'Realtime Score',
      description:
          'Enjoy soccer match score updates in real time without missing a moment',
      imagePath: 'assets/onboarding/onboarding_1.png',
      floaterPath: 'assets/onboarding/onboarding_1_floater.png',
    ),
    OnboardingModel(
      title: 'Full Match Schedule',
      description:
          'The most complete match schedule of every football league in the world',
      imagePath: 'assets/onboarding/onboarding_2.png',
      floaterPath: 'assets/onboarding/onboarding_2_floater.png',
    ),
    OnboardingModel(
      title: 'Latest News Updates',
      description:
          'Enjoy the latest news from the world of football in real time',
      imagePath: 'assets/onboarding/onboarding_3.png',
      floaterPath: 'assets/onboarding/onboarding_3_floater.png',
    ),
  ];
}
