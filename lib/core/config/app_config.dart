class AppConfig {
  static const bool isProduction = false;

  static String get baseUrl {
    return isProduction
        ? 'http://68.233.102.220:3000'
        : 'http://localhost:3000';
  }

  static String get environmentName => isProduction ? 'PROD' : 'DEV';

  // Safety check to prevent production builds with localhost
  static void validateConfig() {
    if (isProduction && baseUrl.contains('localhost')) {
      throw Exception(
        'PRODUCTION BUILD USING LOCALHOST URL! Change isProduction to true in app_config.dart',
      );
    }
  }
}
