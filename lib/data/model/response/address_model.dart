class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? city;
  String? zipcode;
  String? createdAt;
  String? updatedAt;
  int? userId;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? floorNumber;
  String? houseNumber;

  AddressModel(
      {this.id,
      this.addressType,
      this.contactPersonNumber,
      this.address,
      this.latitude,
      this.longitude,
      this.createdAt,
      this.updatedAt,
      this.userId,
        this.city,
        this.zipcode,
      this.method,
      this.contactPersonName,
      this.streetNumber,
      this.floorNumber,
      this.houseNumber,
      });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    method = json['_method'];
    city = json['city'];
    zipcode = json['zipcode'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    floorNumber = json['floor'];
    houseNumber = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    data['city'] = city;
    data['zipcode'] = zipcode;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['floor'] = floorNumber;
    data['house'] = houseNumber;
    return data;
  }
}
