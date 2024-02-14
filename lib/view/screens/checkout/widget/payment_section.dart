import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/custom_shadow_view.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet.dart';
class PaymentSection extends StatelessWidget {
  const PaymentSection({Key? key}) : super(key: key);


  void openDialog(BuildContext context){
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (!CheckOutHelper.isSelfPickup(orderType: orderProvider.orderType) && orderProvider.addressIndex == -1) {
      showCustomSnackBar(getTranslated('select_delivery_address', context),isError: true);
    }else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
      showCustomSnackBar(getTranslated('select_a_time', context),isError: true);
    }else {
      if(!ResponsiveHelper.isMobile()){
        showDialog(
          context: context,
          builder: (con) => const PaymentMethodBottomSheet(),
        );
      }else{
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const PaymentMethodBottomSheet(),
        );
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      bool showPayment = orderProvider.selectedPaymentMethod != null;
      return CustomShadowView(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('payment_method', context), style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

            Flexible(
              child: TextButton(
                onPressed: ()=> openDialog(context),
                child: Text(
                  getTranslated(orderProvider.partialAmount != null || !showPayment ? 'add' : 'change', context),
                  style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
            )
          ]),

          const Divider(height: 1),

           if(orderProvider.partialAmount != null || !showPayment ) Padding(
             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
             child: InkWell(
               onTap: ()=> openDialog(context),
               child: Row(children: [
                 Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                 const SizedBox(width: Dimensions.paddingSizeDefault),

                 Flexible(
                   child: Text(
                     getTranslated('add_payment_method', context),
                     style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
                   ),
                 ),

               ]),
             ),
           ),

           if(showPayment) SelectedPaymentView(total: orderProvider.partialAmount ??  (orderProvider.getCheckOutData?.amount ?? 0)),

          ]),
      );
    });
  }
}


class SelectedPaymentView extends StatelessWidget {
  const SelectedPaymentView({
    Key? key,
    required this.total,
  }) : super(key: key);

  final double total;

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return  Container(
       decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
         borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
         color: Theme.of(context).cardColor,
         border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 1),
       ) : const BoxDecoration(),
       padding: EdgeInsets.symmetric(
         vertical: Dimensions.paddingSizeSmall,
         horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSizeDefault : 0,
       ),

       child: Column(children: [
         Row(children: [
             orderProvider.selectedPaymentMethod?.type == 'online'? CustomImage(
               height: Dimensions.paddingSizeLarge,
               image: '${configModel.baseUrls?.getWayImageUrl}/${orderProvider.paymentMethod?.getWayImage}',
             ) : Image.asset(
               orderProvider.selectedPaymentMethod?.type == 'cash_on_delivery' ? Images.cashOnDelivery : Images.walletPayment,
               width: 20, height: 20, color: Theme.of(context).secondaryHeaderColor,
             ),

             const SizedBox(width: Dimensions.paddingSizeSmall),

             Expanded(child: Text('${orderProvider.selectedPaymentMethod?.getWayTitle}',
               style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
             )),

             Text(
               PriceConverter.convertPrice(context, total), textDirection: TextDirection.ltr,
               style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
             )

           ]),
       ]),
    );
  }
}
