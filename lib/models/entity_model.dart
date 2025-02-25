class EntityModel {
  String? id;
  String? name;
  String? code;
  String? parentId;
  String? entityType;
  String? status;

  EntityModel(
      {this.id,
        this.name,
        this.code,
        this.parentId,
        this.entityType,
        this.status});

  EntityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    parentId = json['parentId'];
    entityType = json['entityType'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['parentId'] = this.parentId;
    data['entityType'] = this.entityType;
    data['status'] = this.status;
    return data;
  }
}