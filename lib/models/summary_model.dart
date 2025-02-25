class SummaryModel {
  String? id;
  String? name;
  String? translation;
  String? totDollar;
  String? totFc;

  SummaryModel(
      {this.id, this.name, this.translation, this.totDollar, this.totFc});

  SummaryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    translation = json['translation'];
    totDollar = json['tot_dollar'];
    totFc = json['tot_fc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['translation'] = translation;
    data['tot_dollar'] = totDollar;
    data['tot_fc'] = totFc;
    return data;
  }
}
