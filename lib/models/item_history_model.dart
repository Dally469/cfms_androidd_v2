class ItemHistory {
  String? title;
  int? amount;
  ItemHistory({
    this.title,
    this.amount,
  });
  ItemHistory.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    amount = json['amount'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['amount'] = this.amount;
    return data;
  }
}
