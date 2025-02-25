class GroupModel {
  String? id;
  String? groupName;
  String? groupCode;

  GroupModel({this.id, this.groupName, this.groupCode});

  GroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupName = json['groupName'];
    groupCode = json['groupCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['groupName'] = this.groupName;
    data['groupCode'] = this.groupCode;
    return data;
  }
}
