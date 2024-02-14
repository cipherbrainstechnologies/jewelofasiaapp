
import 'package:flutter_grocery/data/model/response/product_model.dart';

class FlashDealModel {
  int? totalSize;
  int? limit;
  int? offset;
  FlashDeal? flashDeal;
  List<Product>? products;

  FlashDealModel({this.totalSize, this.limit, this.offset, this.flashDeal, this.products});

  FlashDealModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    flashDeal = json['flash_deal'] != null
        ? FlashDeal.fromJson(json['flash_deal'])
        : null;

    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (flashDeal != null) {
      data['flash_sale'] = flashDeal!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class FlashDeal {
  int? _id;
  String? _title;
  String? _startDate;
  String? _endDate;
  int? _status;
  int? _featured;
  String? _backgroundColor;
  String? _textColor;
  String? _banner;
  String? _slug;
  String? _createdAt;
  String? _updatedAt;
  int? _productId;
  String? _dealType;

  FlashDeal(
      {int? id,
        String? title,
        String? startDate,
        String? endDate,
        int? status,
        int? featured,
        String? backgroundColor,
        String? textColor,
        String? banner,
        String? slug,
        String? createdAt,
        String? updatedAt,
        int? productId,
        String? dealType}) {
    _id = id;
    _title = title;
    _startDate = startDate;
    _endDate = endDate;
    _status = status;
    _featured = featured;
    _backgroundColor = backgroundColor;
    _textColor = textColor;
    _banner = banner;
    _slug = slug;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _productId = productId;
    _dealType = dealType;
  }

  int? get id => _id;
  String? get title => _title;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  int? get status => _status;
  int? get featured => _featured;
  String? get backgroundColor => _backgroundColor;
  String? get textColor => _textColor;
  String? get banner => _banner;
  String? get slug => _slug;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get productId => _productId;
  String? get dealType => _dealType;

  FlashDeal.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _startDate = json['start_date'];
    _endDate = json['end_date'];
    _status = json['status'];
    _featured = json['featured'];
    _backgroundColor = json['background_color'];
    _textColor = json['text_color'];
    _banner = json['image'];
    _slug = json['slug'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _productId = json['product_id'];
    _dealType = json['deal_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _title;
    data['start_date'] = _startDate;
    data['end_date'] = _endDate;
    data['status'] = _status;
    data['featured'] = _featured;
    data['background_color'] = _backgroundColor;
    data['text_color'] = _textColor;
    data['image'] = _banner;
    data['slug'] = _slug;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['product_id'] = _productId;
    data['deal_type'] = _dealType;
    return data;
  }
}
