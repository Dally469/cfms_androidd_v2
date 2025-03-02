class Member {
  int? status;
  String? message;
  List<Data>? data;
  List<ChurchDetails>? churchDetails;
  List<GroupDetails>? groupDetails;


  Member({this.status, this.message, this.data, this.churchDetails, this.groupDetails});

  Member.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    if (json['church_details'] != null) {
      churchDetails = <ChurchDetails>[];
      json['church_details'].forEach((v) {
        churchDetails!.add(ChurchDetails.fromJson(v));
      });
    }
    if (json['group_details'] != null) {
      groupDetails = <GroupDetails>[];
      json['group_details'].forEach((v) {
        groupDetails!.add(GroupDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (churchDetails != null) {
      data['church_details'] =
          churchDetails!.map((v) => v.toJson()).toList();
    }
    if (groupDetails != null) {
      data['group_details'] =
          groupDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? names;
  String? code;
  String? phone;
  Null? registrarPhone;
  String? entityId;
  String? gender;
  String? defaultLanguage;
  String? photo;
  String? locationId;
  String? networkOperator;
  dynamic status;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? cHURCHCode;
  String? cHURCH;
  String? dISTRICT;
  String? cONFERENCE;

  Data(
      {this.id,
        this.names,
        this.code,
        this.phone,
        this.registrarPhone,
        this.entityId,
        this.gender,
        this.defaultLanguage,
        this.photo,
        this.locationId,
        this.networkOperator,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.cHURCHCode,
        this.cHURCH,
        this.dISTRICT,
        this.cONFERENCE});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    names = json['names'];
    code = json['code'];
    phone = json['phone'];
    registrarPhone = json['registrarPhone'];
    entityId = json['entity_id'];
    gender = json['gender'];
    defaultLanguage = json['defaultLanguage'];
    photo = json['photo'];
    locationId = json['locationId'];
    networkOperator = json['networkOperator'];
    status = json['status'] is int
        ? json['status'].toString()
        : json[
            'status']; // Convert int to String if necessary    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
    cHURCHCode = json['CHURCHCode'];
    cHURCH = json['CHURCH'];
    dISTRICT = json['DISTRICT'];
    cONFERENCE = json['CONFERENCE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['names'] = names;
    data['code'] = code;
    data['phone'] = phone;
    data['registrarPhone'] = registrarPhone;
    data['entity_id'] = entityId;
    data['gender'] = gender;
    data['defaultLanguage'] = defaultLanguage;
    data['photo'] = photo;
    data['locationId'] = locationId;
    data['networkOperator'] = networkOperator;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['CHURCHCode'] = cHURCHCode;
    data['CHURCH'] = cHURCH;
    data['DISTRICT'] = dISTRICT;
    data['CONFERENCE'] = cONFERENCE;
    return data;
  }
}

class ChurchDetails {
  String? churchCode;
  String? createdAt;
  String? accountNumber;
  String? bankName;
  String? church;
  String? district;
  String? conference;

  ChurchDetails(
      {this.churchCode,
        this.createdAt,
        this.accountNumber,
        this.bankName,
        this.church,
        this.district,
        this.conference});

  ChurchDetails.fromJson(Map<String, dynamic> json) {
    churchCode = json['ChurchCode'];
    createdAt = json['created_at'];
    accountNumber = json['accountNumber'];
    bankName = json['bankName'];
    church = json['Church'];
    district = json['District'];
    conference = json['Conference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ChurchCode'] = churchCode;
    data['created_at'] = createdAt;
    data['accountNumber'] = accountNumber;
    data['bankName'] = bankName;
    data['Church'] = church;
    data['District'] = district;
    data['Conference'] = conference;
    return data;
  }
}

class GroupDetails {
  String? groupId;
  String? memberId;
  String? groupName;
  String? groupCode;

  GroupDetails({this.groupId, this.memberId, this.groupName, this.groupCode});

  GroupDetails.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    memberId = json['memberId'];
    groupName = json['groupName'];
    groupCode = json['groupCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupId'] = groupId;
    data['memberId'] = memberId;
    data['groupName'] = groupName;
    data['groupCode'] = groupCode;
    return data;
  }
}