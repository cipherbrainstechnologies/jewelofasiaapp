import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/wallet_filter_body.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/wallet_bonus_model.dart';
import 'package:flutter_grocery/data/model/response/wallet_model.dart';
import 'package:flutter_grocery/data/repository/wallet_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/screens/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';

import 'profile_provider.dart';

List<TabButtonModel?> tabButtonList =  [
  TabButtonModel('convert_to_money'.tr, Images.wallet, (){}),
  TabButtonModel('earning'.tr, Images.earningImage, (){}),
  TabButtonModel('converted'.tr, Images.convertedImage, (){}),
];

class WalletProvider with ChangeNotifier {
  final WalletRepo? walletRepo;
  WalletProvider({required this.walletRepo});

  List<Transaction>? _transactionList;
  List<String> _offsetList = [];
  int _offset = 1;
  int? _pageSize;
  bool _isLoading = false;
  String _type = 'all';
  List<WalletFilterBody> _walletFilterList = [];
  List<WalletBonusModel>? _walletBonusList;

  List<Transaction>? get transactionList => _transactionList;
  int? get popularPageSize => _pageSize;
  bool get isLoading => _isLoading;
  int get offset => _offset;
  bool _paginationLoader = false;
  bool get paginationLoader => _paginationLoader;
  String get type => _type;
  List<WalletFilterBody> get walletFilterList => _walletFilterList;
  List<WalletBonusModel>? get walletBonusList => _walletBonusList;

  List<String> walletNoteList = [
    "earn_money_to_your_wallet_by_completing_the_offer",
    "convert_your_loyalty_point_into_wallet_money",
    "admin_also_reward_their_top_customer_with_wallet_money",
    "send_your_wallet_money_while_order"
  ];


  void updatePagination(bool value){
    _paginationLoader = value;
    notifyListeners();
  }


  int? selectedTabButtonIndex;

  set setOffset(int offset) {
    _offset = offset;
  }


  Future<void> getLoyaltyTransactionList(String offset, bool reload, bool fromWallet, {bool isEarning = false}) async {

    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      _transactionList = null;
      if(reload) {
        notifyListeners();
      }

    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ApiResponse apiResponse;
      if(fromWallet){
        apiResponse = await walletRepo!.getWalletTransactionList(offset, _type);
      }else{
        apiResponse = await walletRepo!.getLoyaltyTransactionList(offset, isEarning ? 'earning' : 'converted');
      }



      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if (offset == '1') {
          _transactionList = [];
        }
        _transactionList!.addAll(WalletModel.fromJson(apiResponse.response!.data).data!);
        _pageSize = WalletModel.fromJson(apiResponse.response!.data).totalSize;

        _isLoading = false;
        _paginationLoader = false;
        notifyListeners();
      } else {
        ApiChecker.checkApi(apiResponse);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> pointToWallet(int point, bool fromWallet) async {
    bool isSuccess = false;
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await walletRepo!.pointToWallet(point: point);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      isSuccess = true;
      Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void setCurrentTabButton(int index, {bool isUpdate = true}){
    selectedTabButtonIndex = index;
    if(isUpdate) {
      if(index != 0) {
        getLoyaltyTransactionList('1', true, false, isEarning: index == 1);
      }
      notifyListeners();
    }
  }

  bool checkToken(String token){
    if(walletRepo!.sharedPreferences!.containsKey(token)){
      return false;
    }else{
      walletRepo!.sharedPreferences!.setString(token, token);
      return true;
    }
  }

  Future<void> getWalletBonusList(bool reload) async {
    _walletBonusList = null;
    ApiResponse apiResponse = await walletRepo!.getWalletBonusList();

    _walletBonusList = [];
    if(apiResponse.response?.statusCode == 200) {
      for (var element in apiResponse.response?.data) {
        _walletBonusList?.add(WalletBonusModel.fromJson(element));

      }
    }
    notifyListeners();
  }

  void setWalletFilerType(String type, {bool isUpdate = true}) {
    _type = type;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void insertFilterList(){
    _walletFilterList = [];
    for(int i=0; i < AppConstants.walletTransactionSortingList.length; i++){
      _walletFilterList.add(WalletFilterBody.fromJson(AppConstants.walletTransactionSortingList[i]));
    }
  }

}

