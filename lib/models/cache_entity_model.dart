class CacheEntityModel {
  String? url, data, extra;
  int? cachedAt;

  CacheEntityModel({this.url, required this.data, this.extra, this.cachedAt});

  CacheEntityModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    data = json['data'];
    extra = json['extra'];
    cachedAt = json['saved_at'];
  }
  Map<String, Object?> toJson() {
    return {'url': url, 'data': data, 'saved_at': cachedAt, 'extra': extra};
  }
}
