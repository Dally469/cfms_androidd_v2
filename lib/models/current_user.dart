class CurrentUser {
  int? status;
  String? id;
  String? phone;
  String? model;
  String? name;
  String? church;
  String? position;
  String? accessToken;
  List<ChurchDetails>? churchDetails;

  CurrentUser(
      {this.status,
        this.id,
        this.phone,
        this.model,
        this.name,
        this.church,
        this.position,
        this.accessToken,
        this.churchDetails});

  CurrentUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    id = json['id'];
    phone = json['phone'];
    model = json['model'];
    name = json['name'];
    church = json['church'];
    position = json['position'];
    accessToken = json['accessToken'];
    if (json['churchDetails'] != null) {
      churchDetails = <ChurchDetails>[];
      json['churchDetails'].forEach((v) {
        churchDetails!.add(new ChurchDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['id'] = this.id;
    data['phone'] = this.phone;
    data['model'] = this.model;
    data['name'] = this.name;
    data['church'] = this.church;
    data['position'] = this.position;
    data['accessToken'] = this.accessToken;
    if (this.churchDetails != null) {
      data['churchDetails'] =
          this.churchDetails!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ChurchCode'] = this.churchCode;
    data['created_at'] = this.createdAt;
    data['accountNumber'] = this.accountNumber;
    data['bankName'] = this.bankName;
    data['Church'] = this.church;
    data['District'] = this.district;
    data['Conference'] = this.conference;
    return data;
  }
}