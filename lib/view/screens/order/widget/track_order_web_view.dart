import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/order_constants.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/screens/order/widget/custom_stepper.dart';
import 'package:provider/provider.dart';

class TrackOrderWebView extends StatelessWidget {
  const TrackOrderWebView({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          String status = orderProvider.trackModel?.orderStatus ?? '';

          return orderProvider.trackModel != null && orderProvider.trackModel?.id != null ?   Column(children: [
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(
                '${getTranslated('order_id', context)} #${orderProvider.trackModel!.id}',
                style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              )),

              CustomDirectionality(child: Text(
                PriceConverter.convertPrice(context, orderProvider.trackModel!.orderAmount),
                style: poppinsBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              )),
            ]),
            const Divider(height: Dimensions.paddingSizeExtraLarge),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Image.asset(Images.wareHouse, color: Theme.of(context).primaryColor, width: Dimensions.paddingSizeLarge),
                    const SizedBox(width: 20),

                    if(orderProvider.trackModel?.branchId != null) Text(
                      '${OrderHelper.getBranch(id: orderProvider.trackModel!.branchId!, branchList: splashProvider.configModel?.branches ?? [])?.address}',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ]),
                ),

                if(OrderHelper.isShowDeliveryAddress(orderProvider.trackModel)) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: CustomPaint(
                    size: const Size(50, 2),
                    painter: DashedLineVerticalPainter(isActive: false, axis: Axis.horizontal),
                  ),
                ),

                if(OrderHelper.isShowDeliveryAddress(orderProvider.trackModel)) Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 20),

                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: Text(
                         orderProvider.trackModel?.orderType == 'take_away'
                             ? getTranslated('take_away', context)
                             :  orderProvider.trackModel!.deliveryAddress != null
                             ? orderProvider.trackModel!.deliveryAddress!.address!
                             : getTranslated('address_was_deleted', context),
                        overflow: TextOverflow.ellipsis, maxLines: 1,
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      )),
                  ]),
                ),
              ]),

              if(phoneNumber != null) InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RouteHelper.getOrderDetailsRoute(
                      '${orderProvider.trackModel!.id}',
                      phoneNumber: phoneNumber
                  ));
                },
                child: Container(
                  width: 120, height: 40,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                  ),
                  child: Text(getTranslated('view_details', context), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),

            ]),
            const SizedBox(height: 50),

           status != OrderConstants.canceled && status != OrderConstants.failed && status != OrderConstants.returned ?  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomStepper(
                title: getTranslated('order_placed', context),
                isComplete: status == OrderConstants.pending
                    || status == OrderConstants.confirmed
                    || status == OrderConstants.processing
                    || status == OrderConstants.outForDelivery
                    || status == OrderConstants.delivered,
                isActive: status == OrderConstants.pending,
                statusImage: Images.orderPlace,
                subTitleWidget: Row(children: [
                  const Icon(Icons.schedule, size: Dimensions.fontSizeLarge),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(DateConverter.localDateToIsoStringAMPM(DateConverter.convertStringToDatetime(orderProvider.trackModel!.createdAt!), context),
                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ]),
              ),

              CustomStepper(
                title: getTranslated('order_accepted', context),
                isComplete: status == OrderConstants.confirmed
                    || status == OrderConstants.processing
                    || status == OrderConstants.outForDelivery
                    || status == OrderConstants.delivered,
                isActive: status == OrderConstants.confirmed,
                statusImage: Images.orderAccepted,
              ),

              CustomStepper(
                title: getTranslated('preparing_items', context),
                isComplete: status == OrderConstants.processing
                    || status == OrderConstants.outForDelivery
                    ||status == OrderConstants.delivered,
                statusImage: Images.preparingItems,
                isActive: status == OrderConstants.processing,
              ),

              Consumer<LocationProvider>(builder: (context, locationProvider, _) {
                return CustomStepper(
                  title: getTranslated('order_is_on_the_way', context),
                  isComplete: status == OrderConstants.outForDelivery || status == OrderConstants.delivered,
                  statusImage: Images.outForDelivery,
                  isActive: status == OrderConstants.outForDelivery,
                  subTitleWidget: Text(
                    getTranslated('your_delivery_man_is_coming', context),
                    style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                );
              }),

              CustomStepper(
                height: orderProvider.trackModel?.deliveryMan == null ? 30 : 130,
                title: getTranslated('order_delivered', context),
                isComplete: status == OrderConstants.delivered || status == OrderConstants.canceled,
                isActive: status == OrderConstants.delivered || status == OrderConstants.canceled,
                statusImage: Images.orderDelivered,
                haveTopBar: false,
              ),
            ]) : Text(getTranslated(status == OrderConstants.failed
               ? 'this_order_was_failed' :  status == OrderConstants.canceled
               ? 'this_order_was_canceled'
               : 'this_order_was_returned', context), style: poppinsMedium.copyWith(
             fontSize: Dimensions.fontSizeExtraLarge,
           )),
            const SizedBox(height: 100),

          ]) : const SizedBox();
        }
    );
  }
}
