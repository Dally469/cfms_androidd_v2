
import 'package:intl/intl.dart';

class DonationRecordModel {
  int? id;
  String? donationId;
  String? donationName;
  double? amount;
  String? churchName;
  String? churchCode,narration;
  DateTime? createdAt;
  int? requireNarration;
  bool? isEditable;

  DonationRecordModel({
    this.donationId,
    required this.donationName,
    this.amount,
    this.churchName,
    this.churchCode,
    this.createdAt,
    this.narration,
    this.isEditable,
    this.requireNarration,
  });

  DonationRecordModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    donationId = json['donationId'];
    donationName = json['donationName'];
    amount = json['amount'];
    churchName = json['churchName'];
    churchCode = json['churchCode'];
    createdAt = DateTime.parse(json['createdAt'] as String);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'donationName': donationName,
      'amount': amount,
      'churchName': churchName,
      'churchCode': churchCode,
      'createdAt': DateFormat('yyyy-MM-dd').format(createdAt!),
    };
  }
}
