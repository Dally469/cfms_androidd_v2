class QuickView {
  String? offering;
  String? feeDescription;
  String? feeName;
  String? amount;

  QuickView({this.offering, this.feeDescription, this.feeName, this.amount});

  QuickView.fromJson(Map<String, dynamic> json) {
    offering = json['offering'];
    feeDescription = json['fee_description'];
    feeName = json['title'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['offering'] = offering;
    data['fee_description'] = feeDescription;
    data['fee_name'] = feeName;
    data['amount'] = amount;
    return data;
  }
}
