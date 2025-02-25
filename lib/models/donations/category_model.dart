class DonationsModel {
  int? id;
  String? donationId;
  String? donationName;
  int? amount;

  DonationsModel({this.donationId, this.donationName, this.amount});

  DonationsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    donationId = json['donationId'];
    donationName = json['donationName'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['donationId'] = donationId;
    data['donationName'] = donationName;
    data['amount'] = amount;
    return data;
  }
}