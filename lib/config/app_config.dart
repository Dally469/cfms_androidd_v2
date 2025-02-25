class AppConfig {
  static const String appTitle = 'Church Financial Management System';
  static const String apiBaseUrl = 'https://your-api-url.com/api';

  // Other app-wide configurations
  static const int splashDuration = 3; // seconds
  static const bool enableCrashReporting = true;
  static const int apiTimeout = 30; // seconds

  // Supported languages
  static const List<String> supportedLocales = ['en', 'fr', 'sw', 'rw'];
  static const String fallbackLocale = 'en';
}
