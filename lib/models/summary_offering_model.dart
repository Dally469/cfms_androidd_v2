class SummaryModel {
  String? offeringId;
  String? offering;
  String? total;

  SummaryModel({this.offeringId, this.offering, this.total});

  SummaryModel.fromJson(Map<String, dynamic> json) {
    offeringId = json['offeringId'];
    offering = json['offering'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['offeringId'] = this.offeringId;
    data['offering'] = this.offering;
    data['total'] = this.total;
    return data;
  }
}