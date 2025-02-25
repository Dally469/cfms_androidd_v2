class PaymentHistoryModel {
  String? id;
  String? amount;
  String? trxId;
  String? church;
  String? churchCode;
  String? status;
  String? date;

  PaymentHistoryModel(
      {this.id,
        this.amount,
        this.trxId,
        this.church,
        this.churchCode,
        this.status,
        this.date});

  PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    trxId = json['trxId'];
    church = json['church'];
    churchCode = json['churchCode'];
    status = json['status'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['trxId'] = trxId;
    data['church'] = church;
    data['churchCode'] = churchCode;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}