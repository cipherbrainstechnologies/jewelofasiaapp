class CityModel {
  int? id;
  String? name;
  String? status;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  CityModel(
      {this.id,
        this.name,
        this.status,
        this.deletedAt,
        this.createdAt,
        this.updatedAt});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}