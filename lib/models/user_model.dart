class UserModel {
  String? id;
  String? phone;
  String? name;
  String? church;
  String? churchId;
  String? churchCode;
  String? position;
  String? accessToken;
  List<ChurchDetails>? churchDetails;

  UserModel(
      {this.id,
        this.phone,
        this.name,
        this.church,
        this.churchId,
        this.churchCode,
        this.position,
        this.accessToken,
        this.churchDetails});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    church = json['church'];
    churchId = json['churchId'];
    churchCode = json['churchCode'];
    position = json['position'];
    accessToken = json['accessToken'];
    if (json['churchDetails'] != null) {
      churchDetails = <ChurchDetails>[];
      json['churchDetails'].forEach((v) {
        churchDetails!.add(ChurchDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['name'] = name;
    data['church'] = church;
    data['churchId'] = churchId;
    data['churchCode'] = churchCode;
    data['position'] = position;
    data['accessToken'] = accessToken;
    if (churchDetails != null) {
      data['churchDetails'] =
          churchDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChurchDetails {
  String? churchCode;
  String? createdAt;
  String? accountNumber;
  String? bankName;
  String? church;
  String? district;
  String? conference;

  ChurchDetails(
      {this.churchCode,
        this.createdAt,
        this.accountNumber,
        this.bankName,
        this.church,
        this.district,
        this.conference});

  ChurchDetails.fromJson(Map<String, dynamic> json) {
    churchCode = json['ChurchCode'];
    createdAt = json['created_at'];
    accountNumber = json['accountNumber'];
    bankName = json['bankName'];
    church = json['Church'];
    district = json['District'];
    conference = json['Conference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ChurchCode'] = churchCode;
    data['created_at'] = createdAt;
    data['accountNumber'] = accountNumber;
    data['bankName'] = bankName;
    data['Church'] = church;
    data['District'] = district;
    data['Conference'] = conference;
    return data;
  }
}