class CountryModel {
  final String id;
  final String countryName;
  final String countryCode;
  final String countryShort;
  final String countryFlag;

  CountryModel({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.countryShort,
    required this.countryFlag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      countryName: json['countryName'],
      countryCode: json['countryCode'],
      countryShort: json['countryShort'],
      countryFlag: json['countryFlag'],
    );
  }
}
