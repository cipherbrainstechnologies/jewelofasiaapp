import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/screens/cart/widget/cart_details_view.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_details_button_view.dart';

class OrderAmountView extends StatelessWidget {
  final double itemsPrice;
  final double tax;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double deliveryCharge;
  final double total;
  final bool isVatInclude;
  final List<OrderPartialPayment> paymentList;
  final OrderModel? orderModel;
  final String? phoneNumber;
  final double extraDiscount;

  const OrderAmountView({
    Key? key, required this.itemsPrice, required this.tax, required this.subTotal,
    required this.discount, required this.couponDiscount, required this.deliveryCharge,
    required this.total, required this.isVatInclude,
    required this.paymentList, this.orderModel, this.phoneNumber, required this.extraDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(getTranslated('cost_summery', context), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          Divider(height: 30, thickness: 1, color: Theme.of(context).disabledColor.withOpacity(0.05)),

          ItemView(
            title: 'items_price'.tr,
            subTitle: PriceConverter.convertPrice(context, itemsPrice),
          ),
          const SizedBox(height: 10),

          ItemView(
            title: '${'tax'.tr} ${isVatInclude ? '(${'include'.tr})' : ''}',
            subTitle: '${isVatInclude ? '' : '+'} ${PriceConverter.convertPrice(context, tax)}',
          ),

          Divider(height: 30, thickness: 1, color: Theme.of(context).disabledColor.withOpacity(0.05)),

          ItemView(
            title: 'subtotal'.tr,
            subTitle: PriceConverter.convertPrice(context, subTotal),
          ),
          const SizedBox(height: 10),

          ItemView(
            title: 'discount'.tr,
            subTitle: '- ${PriceConverter.convertPrice(context, discount)}',
          ),
          const SizedBox(height: 10),

          ItemView(
            title: 'coupon_discount'.tr,
            subTitle: '- ${PriceConverter.convertPrice(context, couponDiscount)}',
          ),
          const SizedBox(height: 10),

          extraDiscount > 0 ? ItemView(
            title: 'extra_discount'.tr,
            subTitle: '- ${PriceConverter.convertPrice(context, extraDiscount)}',
          ) : const SizedBox(),
          SizedBox(height: extraDiscount > 0 ? 10 : 0),

          ItemView(
            title: 'delivery_fee'.tr,
            subTitle: '+ ${PriceConverter.convertPrice(context, deliveryCharge)}',
          ),

          Divider(height: 30, thickness: 1, color: Theme.of(context).disabledColor.withOpacity(0.05)),

          ItemView(
            title: 'total_amount'.tr,
            subTitle: PriceConverter.convertPrice(context, total),
            style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),

          if(paymentList.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
            child: DottedBorder(
              borderType: BorderType.RRect,
              color: Theme.of(context).primaryColor,
              strokeWidth: 2,
              dashPattern: const [5, 5],
              radius: const Radius.circular(Dimensions.radiusSizeDefault),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.02),
                ),
                padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: Column(children: paymentList.map((payment) => payment.id != null ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Text("${getTranslated(payment.paidAmount! > 0 ? 'paid_amount' : 'due_amount', context)} (${ payment.paidWith != null && payment.paidWith!.isNotEmpty ? '${payment.paidWith?[0].toUpperCase()}${payment.paidWith?.substring(1).replaceAll('_', ' ')}' : getTranslated('${payment.paidWith}', context)})",
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                      overflow: TextOverflow.ellipsis,),

                    Text(PriceConverter.convertPrice(context, payment.paidAmount! > 0 ? payment.paidAmount : payment.dueAmount),
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ],
                  ),
                ) : const SizedBox()).toList()),
              ),
            ),
          ),

          if(ResponsiveHelper.isDesktop(context)) Column(children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),
            OrderDetailsButtonView(orderModel: orderModel, phoneNumber: phoneNumber),
          ]),

        ]),
    );
  }
}
