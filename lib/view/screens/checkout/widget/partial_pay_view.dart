import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

import 'partial_pay_dialog.dart';

class PartialPayView extends StatelessWidget {
  final double totalPrice;
  const PartialPayView({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<OrderProvider>(builder: (ctx, orderProvider, _) {

      bool isPartialPayment = CheckOutHelper.isPartialPayment(
        configModel: splashProvider.configModel!,
        isLogin: authProvider.isLoggedIn(),
        userInfoModel:profileProvider.userInfoModel,
      );

      bool isSelected = CheckOutHelper.isPartialPaymentSelected(
        paymentMethodIndex: orderProvider.paymentMethodIndex,
        selectedPaymentMethod: orderProvider.selectedPaymentMethod,
      );

      return isPartialPayment ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.01),
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          image: !ResponsiveHelper.isDesktop(context) ? DecorationImage(
            alignment: Alignment.bottomRight,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
            image: const AssetImage(Images.walletPayment
            ),
          ) : null,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(Images.walletBackground, height: 30, width: 30),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  PriceConverter.convertPrice(
                    context, (orderProvider.partialAmount != null || isSelected)
                      && totalPrice < profileProvider.userInfoModel!.walletBalance!
                      ? totalPrice : profileProvider.userInfoModel!.walletBalance!,
                  ),
                  style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  orderProvider.partialAmount != null || isSelected
                      ? getTranslated('has_paid_by_your_wallet', context)
                      : getTranslated('your_have_balance_in_your_wallet', context),
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ])),

          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            orderProvider.partialAmount != null || isSelected ? Row(children: [
              Container(
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(
                getTranslated('applied', context),
                style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              )
            ]) : Flexible(
              child: Text(
                getTranslated('do_you_want_to_use_now', context),
                style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              ),
            ),

            Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return InkWell(
                  onTap: (){
                    if(orderProvider.partialAmount != null || isSelected){
                      orderProvider.changePartialPayment();
                      orderProvider.savePaymentMethod(index: null, method: null);
                    }else{
                      showDialog(context: context, builder: (ctx)=> PartialPayDialog(
                        isPartialPay: profileProvider.userInfoModel!.walletBalance! < totalPrice,
                        totalPrice: totalPrice,
                      ));
                    }
                  },
                  child: locationProvider.addressList == null && orderProvider.isDistanceLoading ? const SizedBox() : Container(
                    decoration: BoxDecoration(
                      color: orderProvider.partialAmount != null || isSelected ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                      border: Border.all(color: orderProvider.partialAmount != null || isSelected ? Colors.red : Theme.of(context).primaryColor, width: 0.5),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                    child: Text(
                      orderProvider.partialAmount != null || isSelected ? getTranslated('remove', context): getTranslated('use', context),
                      style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderProvider.partialAmount != null || isSelected ? Colors.red : Colors.white),
                    ),
                  ),
                );
              }
            ),

          ]),

          isSelected ? Text(
            '${getTranslated('remaining_wallet_balance', context)}: ${PriceConverter.convertPrice(context, profileProvider.userInfoModel!.walletBalance! - totalPrice)}',
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ) : const SizedBox(),

        ]),
      ) : const SizedBox();
    }
    );

  }
}
