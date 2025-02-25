class PendingOfferingsModel {
  String? id;
  String? phone;
  String? totalAmount;
  String? currency;
  String? createdAt;

  PendingOfferingsModel(
      {this.id, this.phone, this.totalAmount, this.currency, this.createdAt});

  PendingOfferingsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    totalAmount = json['totalAmount'];
    createdAt = json['created_at'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['totalAmount'] = totalAmount;
    data['created_at'] = createdAt;
    data['currency'] = currency;
    return data;
  }
}
