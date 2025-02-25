
import 'package:intl/intl.dart';

class QuickPaymentModel {
  int? id;
  String? name;
  String? phone;
  String? offerings;
  String? churchId;
  String? currency;
  String? totalAmount;
  DateTime? createdAt;


  QuickPaymentModel({this.name, this.phone, this.offerings, this.churchId,
      this.totalAmount,this.currency, this.createdAt});

  QuickPaymentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    offerings = json['offerings'];
    churchId = json['churchId'];
    totalAmount = json['totalAmount'];
    currency = json['currency'];
    createdAt = DateTime.parse(json['createdAt'] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['offerings'] = offerings;
    data['churchId'] = churchId;
    data['totalAmount'] = totalAmount;
    data['currency'] = currency;
    data['createdAt'] = DateFormat('yyyy-MM-dd').format(createdAt!);
    return data;
  }
}