import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/timeslote_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/address/widget/map_widget.dart';
import 'package:flutter_grocery/view/screens/order/widget/ordered_product_list_view.dart';
import 'package:provider/provider.dart';

class OrderInfoView extends StatelessWidget {
  final OrderModel? orderModel;
  final TimeSlotModel? timeSlot;

  const OrderInfoView({Key? key, required this.orderModel, required this.timeSlot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        int itemsQuantity = OrderHelper.getOrderItemQuantity(orderProvider.orderDetails);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Order info
            ResponsiveHelper.isDesktop(context) ? Row(children: [

              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                  Row(children: [

                    Row(children: [
                      Text('${getTranslated('order_id', context)} :', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(orderProvider.trackModel!.id.toString(), style: poppinsSemiBold),
                    ]),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue.withOpacity(0.08)
                            : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor.withOpacity(0.08)
                            : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor.withOpacity(0.08) : ColorResources.colorGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                      ),
                      child: Text(
                        getTranslated(orderProvider.trackModel!.orderStatus, context),
                        style: poppinsRegular.copyWith(color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue
                            : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor
                            : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor : ColorResources.colorGreen),
                      ),
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  timeSlot != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    Row(children: [
                      Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(DateConverter.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context), style: poppinsMedium),
                    ]),
                  ]) : const SizedBox(),
                  SizedBox(height: timeSlot != null ? Dimensions.paddingSizeSmall : 0),

                  Row(children: [

                    Text('${getTranslated(itemsQuantity > 1 ? 'items' : 'item', context)}:', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                    Text('${orderModel?.totalQuantity}', style: poppinsSemiBold),

                  ]),

                ]),
              ),

              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                Text(DateConverter.isoStringToLocalDateOnly(orderProvider.trackModel!.createdAt!), style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeDefault),


              ]),

            ]) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : Row( crossAxisAlignment: CrossAxisAlignment.start, children: [

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                
                  Row(children: [
                    Text('${getTranslated('order_id', context)} : ', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                
                    Text(orderProvider.trackModel!.id.toString(), style: poppinsSemiBold),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(children: [

                    Text('${getTranslated(itemsQuantity > 1 ? 'items' : 'item', context)}:', style: poppinsRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                    Text('${orderModel?.totalQuantity}', style: poppinsSemiBold),

                  ]),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(DateConverter.isoStringToLocalDateOnly(orderProvider.trackModel!.createdAt!), style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  timeSlot != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    Row(children: [
                      Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(DateConverter.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context), style: poppinsMedium),
                    ]),
                  ]) : const SizedBox(),
                
                ]),
              ),

              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start, children: [
                if(orderProvider.trackModel?.orderType != 'delivery') Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                  ),
                  child: Text(
                    getTranslated(orderProvider.trackModel?.orderType == 'pos' ? 'pos_order' : 'self_pickup', context),
                    style: poppinsRegular,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue.withOpacity(0.08)
                        : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor.withOpacity(0.08)
                        : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor.withOpacity(0.08) : ColorResources.colorGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                  ),
                  child: Text(
                    getTranslated(orderProvider.trackModel!.orderStatus, context),
                    style: poppinsRegular.copyWith(color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus ? ColorResources.colorBlue
                        : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus ? ColorResources.ratingColor
                        : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus ? ColorResources.redColor : ColorResources.colorGreen),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderProvider.trackModel!.orderType == 'delivery')  InkWell(
                  onTap: () {
                    if(orderProvider.trackModel!.deliveryAddress != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: orderProvider.trackModel!.deliveryAddress)));
                    }
                    else{
                      showCustomSnackBar(getTranslated('address_not_found', context), isError: true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1.5, color: Theme.of(context).primaryColor.withOpacity(0.1)),
                    ),
                    child: Image.asset(Images.deliveryAddressIcon, color: Theme.of(context).primaryColor, height: 20, width: 20),
                  ),
                ),




              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            /// Payment info
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    getTranslated('payment_info', context),
                    style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const Divider(height: 20),

                  Row(children: [
                    Text('${getTranslated('status', context)} : ', style: poppinsRegular),

                    Text(
                      getTranslated(orderProvider.trackModel!.paymentStatus, context),
                      style: poppinsMedium,
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(children: [
                    Text('${getTranslated('method', context)} : ', style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis),

                    Row(children: [
                      (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty) && orderProvider.trackModel!.paymentMethod == 'cash_on_delivery' ? Text(
                        getTranslated('cash_on_delivery', context), style: poppinsMedium
                      ) : Text(
                        (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty)
                            ? '${orderProvider.trackModel!.paymentMethod![0].toUpperCase()}${orderProvider.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                            : 'Digital Payment', style: poppinsMedium,
                      ),

                    ]),


                  ]),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            const OrderedProductListView(),


            (orderProvider.trackModel!.orderNote != null && orderProvider.trackModel!.orderNote!.isNotEmpty) ? Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
              ),
              child: Text(orderProvider.trackModel!.orderNote!, style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
            ) : const SizedBox(),

          ],
        );
      }
    );
  }
}


