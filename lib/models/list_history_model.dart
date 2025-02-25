class QuickHistoryModel {
  String? id;
  String? amount;
  String? currency;
  String? newTrxId;
  String? count;
  String? date;
  String? status;

  QuickHistoryModel(
      {this.id,
      this.amount,
      this.currency,
      this.newTrxId,
      this.count,
      this.date,
      this.status});

  QuickHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['Amount'];
    currency = json['currency'];
    newTrxId = json['newTrxId'];
    count = json['Count'];
    date = json['Date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['currency'] = currency;
    data['newTrxId'] = newTrxId;
    data['Amount'] = amount;
    data['Count'] = count;
    data['Date'] = date;
    data['status'] = status;
    return data;
  }
}
