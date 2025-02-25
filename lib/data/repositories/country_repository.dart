import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/country_model.dart';

class CountryRepository {
  final String _landingUrl = "https://sdacfms.com/get_countrie";

  Future<List<CountryModel>> getCountrySuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final res = await http
        .get(Uri.parse("$_landingUrl?v=${prefs.getString("version")!}"));

    if (res.statusCode == 200) {
      final List countries = json.decode(res.body);
      return countries
          .map((model) => CountryModel.fromJson(model))
          .where((country) {
        final lowerName = country.countryName?.toLowerCase();
        final queryLower = query.toLowerCase();
        return query.isEmpty || lowerName!.contains(queryLower);
      }).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
