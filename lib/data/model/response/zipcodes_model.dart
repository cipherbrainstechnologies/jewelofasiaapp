class ZipcodesModel {
  int? id;
  int? cityId;
  String? zipcode;
  String? orderBeforeDay;
  String? deliveryOrderDay;
  String? status;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  ZipcodesModel(
      {this.id,
        this.cityId,
        this.zipcode,
        this.orderBeforeDay,
        this.deliveryOrderDay,
        this.status,
        this.deletedAt,
        this.createdAt,
        this.updatedAt});

  ZipcodesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityId = json['city_id'];
    zipcode = json['zipcode'];
    orderBeforeDay = json['order_before_day'];
    deliveryOrderDay = json['delivery_order_day'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['city_id'] = cityId;
    data['zipcode'] = zipcode;
    data['order_before_day'] = orderBeforeDay;
    data['delivery_order_day'] = deliveryOrderDay;
    data['status'] = status;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}