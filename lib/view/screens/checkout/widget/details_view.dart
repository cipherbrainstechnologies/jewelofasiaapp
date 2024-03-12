import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/check_out_data.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_shadow_view.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/payment_section.dart';
import 'package:provider/provider.dart';

import 'partial_pay_view.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({
    Key? key,
    required this.paymentList,
    required this.noteController,
  }) : super(key: key);

  final List<PaymentMethod> paymentList;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    CheckOutData? checkOutData = Provider.of<OrderProvider>(context, listen: false).getCheckOutData;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      const PaymentSection(),

      PartialPayView(totalPrice: checkOutData!.amount! + (checkOutData.deliveryCharge ?? 0)),



      CustomShadowView(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('add_delivery_note', context), style: poppinsRegular),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomTextField(
            fillColor: Theme.of(context).canvasColor,
            isShowBorder: true,
            controller: noteController,
            hintText: getTranslated('type', context),
            maxLines: 5,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ]),
      ),

      if(!ResponsiveHelper.isDesktop(context)) const AmountView(),

    ]);
  }
}

class AmountView extends StatelessWidget {
  const AmountView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =  Provider.of<SplashProvider>(context, listen: false).configModel;

    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {

        CheckOutData? checkOutData = Provider.of<OrderProvider>(context, listen: false).getCheckOutData;
        bool isFreeDelivery = CheckOutHelper.isFreeDeliveryCharge(type: checkOutData?.orderType);
        bool selfPickup = CheckOutHelper.isSelfPickup(orderType: checkOutData?.orderType);
        bool showPayment = orderProvider.selectedPaymentMethod != null;


        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),

           if(CheckOutHelper.isKmWiseCharge(configModel: configModel)) Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('subtotal', context), style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

                CustomDirectionality(child: Text(
                  PriceConverter.convertPrice(context, checkOutData?.amount),
                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  getTranslated('delivery_fee', context),
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                Consumer<OrderProvider>(builder: (context, orderProvider, _) {
                  return CustomDirectionality(
                    child: Text(isFreeDelivery ? getTranslated('free', context): (selfPickup)
                        ? '(+) ${PriceConverter.convertPrice(context, selfPickup
                        ? 0 : checkOutData?.deliveryCharge)}'
                        : getTranslated('not_found', context),
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  );
                }),
              ]),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: CustomDivider(),
              ),
            ]),


           if(orderProvider.partialAmount != null) Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  getTranslated('wallet_payment', context),
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                CustomDirectionality(
                  child: Text(PriceConverter.convertPrice(context, checkOutData!.amount! + (checkOutData.deliveryCharge ?? 0) - (orderProvider.partialAmount ?? 0) ),
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),



             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text( showPayment && orderProvider.selectedPaymentMethod?.type != 'cash_on_delivery'? getTranslated(orderProvider.selectedPaymentMethod?.getWayTitle, context) :
                  '${getTranslated('due_amount', context)} ${orderProvider.selectedPaymentMethod?.type == 'cash_on_delivery'
                      ? '(${getTranslated(orderProvider.selectedPaymentMethod?.type, context)})' : ''}',
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                CustomDirectionality(
                  child: Text(PriceConverter.convertPrice(context, orderProvider.partialAmount ??  (orderProvider.getCheckOutData?.amount ?? 0)),
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),

              ]),

              const SizedBox(height: Dimensions.paddingSizeLarge),

            ]),


           if(ResponsiveHelper.isDesktop(context)) TotalAmountView(
             amount: checkOutData?.amount ?? 0,
             freeDelivery: isFreeDelivery,
             deliveryCharge: checkOutData?.deliveryCharge ?? 0,
           ),

          ]),
        );
      }
    );
  }
}

class TotalAmountView extends StatelessWidget {
  const TotalAmountView({
    Key? key,
    required this.amount,
    required this.freeDelivery,
    required this.deliveryCharge,
  }) : super(key: key);

  final double amount;
  final bool freeDelivery;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(getTranslated('total_amount', context), style: poppinsMedium.copyWith(
        fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
      )),

      Flexible(
        child: CustomDirectionality(child: Text(
          PriceConverter.convertPrice(context, amount + (freeDelivery ? 0 :  deliveryCharge)),
          style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
        )),
      ),
    ]);
  }
}