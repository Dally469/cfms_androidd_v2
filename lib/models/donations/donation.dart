class DonationModel {
  String? id;
  String? donationId;
  String? donationName;
  String? amount;
  String? narration;

  DonationModel({this.donationId, this.donationName, this.amount, this.narration});

  DonationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    donationId = json['donationId'];
    donationName = json['donationName'];
    amount = json['amount'];
    narration = json['narration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['donationId'] = donationId;
    data['donationName'] = donationName;
    data['amount'] = amount;
    data['narration'] = narration;
    return data;
  }
}