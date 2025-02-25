class CurrencyModel {
  String? title;
  String? code;

  CurrencyModel({this.title, this.code});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['code'] = this.code;
    return data;
  }
}
