class CountryModel {
  String? id;
  String? countryName;
  String? countryCode;
  String? countryShort;
  String? countryFlag;
  String? countryCurrency;
  CountryModel(
      {this.id,
        this.countryName,
        this.countryCode,
        this.countryShort,
        this.countryFlag,
        this.countryCurrency});

  CountryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryName = json['countryName'];
    countryCode = json['countryCode'];
    countryShort = json['countryShort'];
    countryFlag = json['countryFlag'];
    countryCurrency = json['countryCurrency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['countryName'] = this.countryName;
    data['countryCode'] = this.countryCode;
    data['countryShort'] = this.countryShort;
    data['countryFlag'] = this.countryFlag;
    data['countryCurrency'] = this.countryCurrency;
    return data;
  }
}