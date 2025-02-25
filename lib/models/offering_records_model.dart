
import 'package:intl/intl.dart';

class OfferingRecordModel {
  int? id;
  String? memberId;
  String? memberPhone;
  String? offeringId;
  String? narration;
  String? churchCode;
  String? amount;
  DateTime? createdAt;


  OfferingRecordModel({this.memberId, this.offeringId, this.narration, this.churchCode,
      this.amount, this.createdAt});

  OfferingRecordModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    memberId = json[''];
    offeringId = json['offeringId'];
    narration = json['narration'];
    churchCode = json['churchCode'];
    amount = json['amount'];
    createdAt = DateTime.parse(json['createdAt'] as String);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'offeringId': offeringId,
      'narration': narration,
      'churchCode': churchCode,
      'amount': amount,
      'createdAt': DateFormat('yyyy-MM-dd').format(createdAt!),
    };
  }
}
