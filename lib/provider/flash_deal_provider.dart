import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/flash_deal_model.dart';
import 'package:flutter_grocery/data/repository/product_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/helper/date_converter.dart';

class FlashDealProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  FlashDealProvider({required this.productRepo});

  FlashDealModel? _flashDealModel;
  Duration? _duration;
  Timer? _timer;
  Duration? get duration => _duration;
  int? _currentIndex;
  int? get currentIndex => _currentIndex;
  FlashDealModel? get flashDealModel => _flashDealModel;


  Future<void> getFlashDealProducts(int offset, bool reload, {bool isUpdate = true}) async {
    if(reload) {
      _flashDealModel = null;
      if(isUpdate) {
        notifyListeners();
      }
    }

    ApiResponse? response = await productRepo.getFlashDeal(offset);
    if (response.response != null && response.response?.data != null && response.response?.statusCode == 200) {
      if(offset == 1){
        _flashDealModel = FlashDealModel.fromJson(response.response?.data);
      } else {
        _flashDealModel!.totalSize = FlashDealModel.fromJson(response.response?.data).totalSize;
        _flashDealModel!.offset = FlashDealModel.fromJson(response.response?.data).offset;
        _flashDealModel!.flashDeal = FlashDealModel.fromJson(response.response?.data).flashDeal;
        _flashDealModel!.products!.addAll(FlashDealModel.fromJson(response.response?.data).products!);
      }

      if(_flashDealModel != null && _flashDealModel?.flashDeal != null && _flashDealModel!.flashDeal!.endDate != null) {
        DateTime endTime = DateConverter.isoStringToLocalDate(_flashDealModel!.flashDeal!.endDate!);
        _duration = endTime.difference(DateTime.now());
        _timer?.cancel();
        _timer = null;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = _duration! - const Duration(seconds: 1);
          notifyListeners();
        });
      }

      notifyListeners();

    } else {
      ApiChecker.checkApi(response);
    }

  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
