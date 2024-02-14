import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/screens/address/widget/adress_widget.dart';
import 'package:provider/provider.dart';

class AddAddressDialog extends StatelessWidget {
  const AddAddressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final  OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Dialog(child: Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        bool isNotEmptyAddress = (locationProvider.addressList != null && locationProvider.addressList!.isNotEmpty);

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          width: (Dimensions.webScreenWidth / 2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                onPressed: ()=> Navigator.pop(context),
                icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
              ),
            ]),

            Text(getTranslated(isNotEmptyAddress ? 'select_form_saved_address' : 'you_have_to_save_address' , context),
              style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // if(isNotEmptyAddress) const CurrentLocationButton(isBorder: false),


            if(!isNotEmptyAddress) Image.asset(Images.locationBannerImage, height: 120, width: 120),

            if(!isNotEmptyAddress) Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeExtraSmall),
              child: Text(
                getTranslated('you_dont_have_any_saved_address_yet', context),
                style: poppinsLight,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Flexible(child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: locationProvider.addressList?.length,
                  itemBuilder: (context, index) {
                    return Center(child: SizedBox(width: 700, child: AddressWidget(
                      fromSelectAddress: true,
                      addressModel: locationProvider.addressList![index],
                      index: index,
                    )));
                  },
                ) : const SizedBox() : const Center(child: CircularProgressIndicator()),

              ]),
            )),

            // if(!isNotEmptyAddress) const CurrentLocationButton(isBorder: true),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, RouteHelper.getAddAddressRoute('checkout', 'add', AddressModel()));
                await locationProvider.initAddressList();

                CheckOutHelper.selectDeliveryAddressAuto(
                  isLoggedIn: true,
                  orderType: orderProvider.getCheckOutData?.orderType,
                  lastAddress: null,
                );

              },
              icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
              label: Text(getTranslated('add_new_address', context), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor)),
            ),

           isNotEmptyAddress? CustomButton(
              margin: Dimensions.paddingSizeDefault,
              buttonText: getTranslated('select', context), onPressed: ()=>  Navigator.pop(context),
            ) : const SizedBox(height: Dimensions.paddingSizeDefault),

          ]),
        );
      }
    ));
  }
}

class CurrentLocationButton extends StatelessWidget {
  final bool isBorder;
  const CurrentLocationButton({
    Key? key, required this.isBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: (){
        Navigator.pop(context);
        Navigator.pushNamed(context, RouteHelper.getAddAddressRoute('checkout', 'add', AddressModel()));
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault))),
        fixedSize: const Size(200, 40),
        backgroundColor: isBorder ?  Theme.of(context).primaryColor : Theme.of(context).cardColor,
      ),
      icon:  Icon(
        Icons.my_location,
        color: isBorder ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
      ),
      label: Text(getTranslated('use_my_current_location', context), style:  poppinsRegular.copyWith(
        fontSize: Dimensions.fontSizeExtraSmall,
        color: isBorder ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
      )),

    );
  }
}
