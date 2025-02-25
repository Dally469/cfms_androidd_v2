import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepository {
  final SharedPreferences prefs;
  static const String _languageKey = 'language';

  LanguageRepository({required this.prefs});

  Future<bool> setLanguage(String languageCode) async {
    return await prefs.setString(_languageKey, languageCode);
  }

  Future<String?> getLanguage() async {
    return prefs.getString(_languageKey);
  }
}
