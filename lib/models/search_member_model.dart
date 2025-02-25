class MemberSearchModel {
  List<Records>? records;
  int? count;

  MemberSearchModel({this.records, this.count});

  MemberSearchModel.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class Records {
  String? id;
  String? names;
  String? phone;
  String? createdAt;
  String? church;

  Records({this.id, this.names, this.phone, this.createdAt, this.church});

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    names = json['names'];
    phone = json['phone'];
    createdAt = json['created_at'];
    church = json['church'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['names'] = this.names;
    data['phone'] = this.phone;
    data['created_at'] = this.createdAt;
    data['church'] = this.church;
    return data;
  }
}
