class MemberLocalModel {
  int? id;
  String? phone;
  String? name;
  String? churchCode;

  MemberLocalModel({
        this.name,
        this.phone,
        this.churchCode,});

  MemberLocalModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    churchCode = json['churchCode'];
    }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['churchCode'] = churchCode;

    return data;
  }
}