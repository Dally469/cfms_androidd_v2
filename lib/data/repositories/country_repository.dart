import 'dart:convert';
import 'package:cfms/models/country_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CountryRepository {
  final String _landingUrl = 'https://sdacfms.com/get_countries';

  Future<List<CountryModel>> fetchCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http
        .get(Uri.parse("$_landingUrl?v=${prefs.getString("version")!}"));
print(response.body);
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CountryModel.fromJson(json)).toList();
    } else {
      // If the server does not return a 200 response, throw an exception.
      throw Exception('Failed to load countries');
    }
  }
}
