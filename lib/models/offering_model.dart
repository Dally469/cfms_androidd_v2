class OfferingModel {
  String? id,name,translation;
  int? requireNarration;

  OfferingModel({this.id, this.name, this.translation, this.requireNarration});

  OfferingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    translation = json['translation'];
    requireNarration = int.parse(json['require_narration']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['translation'] = translation;
    data['require_narration'] = requireNarration;
    return data;
  }
}