// lib/config/app_config.dart

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://meal-recomendation-be.vercel.app',
  );

  static Uri apiUri(String path) {
    return Uri.parse('$apiBaseUrl$path');
  }
}
