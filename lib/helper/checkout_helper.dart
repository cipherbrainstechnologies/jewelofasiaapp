import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/model/response/offline_payment_model.dart';
import 'package:flutter_grocery/data/model/response/userinfo_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {
  static List<PaymentMethod> getActivePaymentList({required ConfigModel configModel}){
    List<PaymentMethod> paymentMethodList = [];

    if(configModel.cashOnDelivery!) {
      paymentMethodList.add(PaymentMethod(getWay: 'cash_on_delivery', getWayImage: Images.cashOnDelivery));
    }

    if(configModel.offlinePayment!) {
      paymentMethodList.add(PaymentMethod(getWay: 'offline_payment', getWayImage: Images.walletPayment));
    }

    if(configModel.walletStatus!) {
      paymentMethodList.add(PaymentMethod(getWay: 'wallet_payment', getWayImage: Images.walletPayment));
    }

    paymentMethodList.addAll(configModel.activePaymentMethodList ?? []);

    return paymentMethodList;
  }

  static double getDeliveryCharge({
    required double orderAmount,
    required double distance,
    required double discount,
    required String? freeDeliveryType,
    required ConfigModel configModel,
  }) {
    final deliveryManagement = configModel.deliveryManagement;
    final bool freeDeliveryStatus = configModel.freeDeliveryStatus ?? false;
    final freeDeliveryOverAmount = configModel.freeDeliveryOverAmount;

    double deliveryCharge = distance * (deliveryManagement?.shippingPerKm ?? 0);

    if (deliveryCharge < (deliveryManagement?.minShippingCharge ?? 0)) {
      deliveryCharge = deliveryManagement?.minShippingCharge ?? 0;
    }

    final isDeliveryDisabled = !(deliveryManagement?.status ?? false) || distance == -1;
    final isFreeDeliveryEligible = freeDeliveryStatus && (orderAmount + discount) > (freeDeliveryOverAmount ?? 0);

    if (isDeliveryDisabled || isFreeDeliveryEligible || freeDeliveryType == 'free_delivery') {
      deliveryCharge = 0;
    }

    return deliveryCharge;
  }


  static bool isBranchAvailable({required List<Branches> branches, required Branches selectedBranch, required AddressModel selectedAddress}){
    bool isAvailable = branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    if(!isAvailable) {
      double distance = Geolocator.distanceBetween(
        double.parse(selectedBranch.latitude!), double.parse(selectedBranch.longitude!),
        double.parse(selectedAddress.latitude!), double.parse(selectedAddress.longitude!),
      ) / 1000;

      isAvailable = distance < selectedBranch.coverage!;
    }

    return isAvailable;
  }

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }){
    AddressModel? deliveryAddress;
    if(selectedAddress != null) {
      deliveryAddress = selectedAddress;
    }else if(lastOrderAddress != null){
      deliveryAddress = lastOrderAddress;
    }else if(addressList != null && addressList.isNotEmpty){
      deliveryAddress = addressList.first;
    }

    return deliveryAddress;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) => configModel != null &&  configModel.deliveryManagement!.status!;

  static bool isFreeDeliveryCharge({required String? type}) => type == 'free_delivery';

  static bool isSelfPickup({required String? orderType}) => orderType == 'self_pickup';

  static Future<void> selectDeliveryAddress({
    required bool isAvailable,
    required int index,
    required ConfigModel configModel,
    required LocationProvider locationProvider,
    required OrderProvider orderProvider,
    required bool fromAddressList,
  }) async {

    if(isAvailable) {

      locationProvider.updateAddressIndex(index, fromAddressList);
      orderProvider.setAddressIndex(index, notify: true);


      if(CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        if(fromAddressList) {
          if(orderProvider.selectedPaymentMethod != null){
            showCustomSnackBar(getTranslated('your_payment_method_has_been', Get.context!), isError: false);
          }
          orderProvider.savePaymentMethod(index: null, method: null);
          orderProvider.changePartialPayment();

        }
        showDialog(context: Get.context!, builder: (context) => Center(child: Container(
          height: 100, width: 100, alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
          child: CustomLoader(color: Theme.of(context).primaryColor),
        )), barrierDismissible: false);

        bool isSuccess = await orderProvider.getDistanceInMeter(
          LatLng(
            double.parse(configModel.branches![orderProvider.branchIndex].latitude!),
            double.parse(configModel.branches![orderProvider.branchIndex].longitude!),
          ),
          LatLng(
            double.parse(locationProvider.addressList![index].latitude!),
            double.parse(locationProvider.addressList![index].longitude!),
          ),
        );

        Navigator.pop(Get.context!);

        if(fromAddressList) {
          await showDialog(context: Get.context!, builder: (context) => DeliveryFeeDialog(
            freeDelivery: orderProvider.getCheckOutData?.freeDeliveryType == 'free_delivery',
            amount: orderProvider.getCheckOutData?.amount ?? 0,
            distance: orderProvider.distance,
            callBack: (deliveryCharge){
              orderProvider.getCheckOutData?.copyWith(deliveryCharge: deliveryCharge);
            },
          ));
        }else{
          orderProvider.getCheckOutData?.copyWith(deliveryCharge: CheckOutHelper.getDeliveryCharge(
            freeDeliveryType: orderProvider.getCheckOutData?.freeDeliveryType,
            orderAmount: orderProvider.getCheckOutData?.amount ?? 0,
            distance: orderProvider.distance,
            discount: orderProvider.getCheckOutData?.placeOrderDiscount ?? 0,
            configModel: configModel,
          ));
        }

        if(!isSuccess){
          showCustomSnackBar(getTranslated('failed_to_fetch_distance', Get.context!));
        }

  }

      orderProvider.savePaymentMethod(index: null, method: null);
      orderProvider.changePartialPayment();
    }
  }


  static bool isWalletPayment({required ConfigModel configModel, required bool isLogin, required double? partialAmount, required bool isPartialPayment}){
    return configModel.walletStatus! &&  isLogin && (partialAmount == null) && !isPartialPayment;
  }

  static bool isPartialPayment({required ConfigModel configModel, required bool isLogin, required UserInfoModel? userInfoModel}){
   return isLogin && configModel.isPartialPayment! && configModel.walletStatus! && (userInfoModel != null && userInfoModel.walletBalance! > 0);
  }

  static bool isPartialPaymentSelected({required int? paymentMethodIndex, required PaymentMethod? selectedPaymentMethod}){
    return (paymentMethodIndex == 1 && selectedPaymentMethod != null);
  }

  static List<Map<String, dynamic>> getOfflineMethodJson(List<MethodField>? methodList){
    List<Map<String, dynamic>> mapList = [];
    List<String?> keyList = [];
    List<String?> valueList = [];

    for(MethodField methodField in (methodList ?? [])){
      keyList.add(methodField.fieldName);
      valueList.add(methodField.fieldData);
    }

    for(int i = 0; i < keyList.length; i++) {
      mapList.add({'${keyList[i]}' : '${valueList[i]}'});
    }

    return mapList;
  }

  static selectDeliveryAddressAuto({AddressModel? lastAddress, required bool isLoggedIn, required String? orderType}) async {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(Get.context!, listen: false);
    final OrderProvider orderProvider = Provider.of<OrderProvider>(Get.context!, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(Get.context!, listen: false);

    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: orderProvider.addressIndex == -1 ? null : locationProvider.addressList?[orderProvider.addressIndex],
      lastOrderAddress: lastAddress,
    );


    if(isLoggedIn && deliveryAddress != null && orderType == 'delivery' && locationProvider.getAddressIndex(deliveryAddress) != null){

      await CheckOutHelper.selectDeliveryAddress(
        isAvailable: true,
        index: locationProvider.getAddressIndex(deliveryAddress)!,
        configModel: splashProvider.configModel!,
        locationProvider: locationProvider, orderProvider: orderProvider,
        fromAddressList: false,
      );
    }
  }




}