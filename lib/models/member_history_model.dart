class MemberHistoryModel {
  List<MemberInfo>? memberInfo;
  List<PaymentInfo>? paymentInfo;

  MemberHistoryModel({this.memberInfo, this.paymentInfo});

  MemberHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['memberInfo'] != null) {
      memberInfo = <MemberInfo>[];
      json['memberInfo'].forEach((v) {
        memberInfo!.add(new MemberInfo.fromJson(v));
      });
    }
    if (json['paymentInfo'] != null) {
      paymentInfo = <PaymentInfo>[];
      json['paymentInfo'].forEach((v) {
        paymentInfo!.add(new PaymentInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.memberInfo != null) {
      data['memberInfo'] = this.memberInfo!.map((v) => v.toJson()).toList();
    }
    if (this.paymentInfo != null) {
      data['paymentInfo'] = this.paymentInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberInfo {
  String? names;
  String? code;
  String? phone;
  String? gender;
  String? church;
  String? id;
  String? level;
  String? structure;

  MemberInfo(
      {this.names,
        this.code,
        this.phone,
        this.gender,
        this.church,
        this.id,
        this.level,
        this.structure});

  MemberInfo.fromJson(Map<String, dynamic> json) {
    names = json['names'];
    code = json['code'];
    phone = json['phone'];
    gender = json['gender'];
    church = json['church'];
    id = json['id'];
    level = json['level'];
    structure = json['structure'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['names'] = this.names;
    data['code'] = this.code;
    data['phone'] = this.phone;
    data['gender'] = this.gender;
    data['church'] = this.church;
    data['id'] = this.id;
    data['level'] = this.level;
    data['structure'] = this.structure;
    return data;
  }
}

class PaymentInfo {
  String? trxId;
  String? amount;
  String? updatedAt;
  String? status;
  String? currency;
  String? details;
  String? count;

  PaymentInfo(
      {this.trxId,
        this.amount,
        this.updatedAt,
        this.status,
        this.currency,
        this.details,
        this.count});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    trxId = json['trxId'];
    amount = json['amount'];
    updatedAt = json['updated_at'];
    status = json['status'];
    currency = json['currency'];
    details = json['details'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trxId'] = this.trxId;
    data['amount'] = this.amount;
    data['updated_at'] = this.updatedAt;
    data['status'] = this.status;
    data['currency'] = this.currency;
    data['details'] = this.details;
    data['count'] = this.count;
    return data;
  }
}
