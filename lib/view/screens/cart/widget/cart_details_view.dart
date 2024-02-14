import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/cart/widget/delivery_option_button.dart';
import 'package:provider/provider.dart';

class CartDetailsView extends StatelessWidget {
  const CartDetailsView({
    Key? key,
    required TextEditingController couponController,
    required double total,
    required bool isSelfPickupActive,
    required bool kmWiseCharge,
    required bool isFreeDelivery,
    required double itemPrice,
    required double tax,
    required double discount,
    required this.deliveryCharge,
  }) : _couponController = couponController, _total = total, _isSelfPickupActive = isSelfPickupActive, _kmWiseCharge = kmWiseCharge, _isFreeDelivery = isFreeDelivery, _itemPrice = itemPrice, _tax = tax, _discount = discount, super(key: key);

  final TextEditingController _couponController;
  final double _total;
  final bool _isSelfPickupActive;
  final bool _kmWiseCharge;
  final bool _isFreeDelivery;
  final double _itemPrice;
  final double _tax;
  final double _discount;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    return Column(children: [

      _isSelfPickupActive ? Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('delivery_option', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          DeliveryOptionButton(value: 'delivery', title: getTranslated('home_delivery', context), kmWiseFee: _kmWiseCharge, freeDelivery: _isFreeDelivery),

          DeliveryOptionButton(value: 'self_pickup', title: getTranslated('self_pickup', context), kmWiseFee: _kmWiseCharge),

        ]),
      ) : const SizedBox(),
      SizedBox(height: _isSelfPickupActive ? Dimensions.paddingSizeDefault : 0),

      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Consumer<CouponProvider>(
            builder: (context, couponProvider, child) {
              return CouponView(couponController: _couponController, total: _total, deliveryCharge: deliveryCharge);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Total
          Text(getTranslated('cost_summery', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          Divider(height: 30, thickness: 1, color: Theme.of(context).disabledColor.withOpacity(0.05)),

          ItemView(
            title: getTranslated('items_price', context),
            subTitle: PriceConverter.convertPrice(context, _itemPrice),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ItemView(
            title: '${getTranslated('tax', context)} ${configModel.isVatTexInclude! ? '(${getTranslated('include', context)})' : ''}',
            subTitle: '${ configModel.isVatTexInclude! ?  '' : '+'} ${PriceConverter.convertPrice(context, _tax)}',
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ItemView(
            title: getTranslated('discount', context),
            subTitle: '- ${PriceConverter.convertPrice(context, _discount)}',
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),


          Consumer<CouponProvider>(builder: (context, couponProvider, _) {
            return couponProvider.couponType != 'free_delivery' && couponProvider.discount! > 0 ? Padding(
              padding: EdgeInsets.symmetric(vertical: couponProvider.couponType != 'free_delivery' && couponProvider.discount! > 0 ? Dimensions.paddingSizeSmall : 0),
              child: ItemView(
                title: getTranslated('coupon_discount', context),
                subTitle: '- ${PriceConverter.convertPrice(context, couponProvider.discount)}',
              ),
            ) : const SizedBox();
          }),


          if (_kmWiseCharge || _isFreeDelivery) const SizedBox() else ItemView(
            title: getTranslated('delivery_fee', context),
            subTitle: PriceConverter.convertPrice(context, deliveryCharge),
          ),

          Divider(height: 30, thickness: 1, color: Theme.of(context).disabledColor.withOpacity(0.1)),

          ItemView(
            title: getTranslated(_kmWiseCharge ? 'subtotal' : 'total_amount', context),
            subTitle: PriceConverter.convertPrice(context, _total),
            style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
          ),

        ]),
      ),

    ]);
  }
}

class ItemView extends StatelessWidget {
  const ItemView({Key? key, required this.title, required this.subTitle, this.style}) : super(key: key);

  final String title;
  final String subTitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor)),

      CustomDirectionality(child: Text(
        subTitle,
        style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
      )),
    ]);
  }
}

class CouponView extends StatelessWidget {
  const CouponView({Key? key, required this.couponController, required this.total, required this.deliveryCharge,})
      : super(key: key);

  final TextEditingController couponController;
  final double total;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        return DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).primaryColor,
          strokeWidth: 2,
          dashPattern: const [5, 5],
          child: Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeExtraSmall),
            child: SizedBox(
              height: 50,
              child: Row(children: [

                Image.asset(Images.couponApply, height: 30, width: 30),

                Expanded(child: TextField(
                  controller: couponController,
                  style: poppinsMedium,
                  decoration: InputDecoration(
                    hintText: getTranslated('enter_promo_code', context),
                    hintStyle: poppinsRegular.copyWith(color: Theme.of(context).hintColor),
                    isDense: true,
                    filled: true,
                    enabled: couponProvider.discount == 0,
                    fillColor: Theme.of(context).cardColor,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )),

                InkWell(
                  onTap: () {
                    if (couponController.text.isNotEmpty && !couponProvider.isLoading) {
                      if (couponProvider.discount! < 1) {
                        couponProvider.applyCoupon(couponController.text, (total - deliveryCharge));
                      } else {
                        couponProvider.removeCouponData(true);
                      }
                    }else {
                      showCustomSnackBar(getTranslated('invalid_code_or_failed', context),isError: true);
                    }
                  },
                  child: couponProvider.discount! <= 0 ? Container(
                    height: 40,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeTen),),
                    ),
                    child: !couponProvider.isLoading ? Text(
                      getTranslated('apply', context),
                      style: poppinsMedium.copyWith(color: Colors.white),
                    ) : const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  ) : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                )
              ]),
            ),
          ),
        );
      }
    );
  }
}