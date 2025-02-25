class AppState {
  final bool showHome;
  final String json;
  final bool isLoggedIn;
  final String version;
  final String buildNumber;

  const AppState({
    required this.showHome,
    required this.json,
    required this.isLoggedIn,
    required this.version,
    required this.buildNumber,
  });
}
