
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ButtonsView extends StatelessWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController locationTextController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController floorNumberController;
  final AddressModel? address;
  final String countryCode;
  final int city;
  final String zipcode;

  const ButtonsView({
    Key? key,
    required this.isEnableUpdate,
    required this.fromCheckout,
    required this.contactPersonNumberController,
    required this.contactPersonNameController,
    required this.address,
    required this.streetNumberController,
    required this.floorNumberController,
    required this.houseNumberController,
    required this.countryCode, required this.locationTextController, required this.city, required this.zipcode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return Column(children: [

      locationProvider.addressStatusMessage != null ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          locationProvider.addressStatusMessage!.isNotEmpty ? const CircleAvatar(backgroundColor: Colors.green, radius: 5) : const SizedBox.shrink(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationProvider.addressStatusMessage ?? "",
              style:
              Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green, height: 1),
            ),
          )
        ],
      )  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          locationProvider.errorMessage!.isNotEmpty
              ? const CircleAvatar(backgroundColor: Colors.red, radius: 5)
              : const SizedBox.shrink(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationProvider.errorMessage ?? "",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.red, height: 1),
            ),
          )
        ],
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Container(
        height: 50.0,
        width: Dimensions.webScreenWidth,
        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: !locationProvider.isLoading ? CustomButton(
          buttonText: isEnableUpdate ? getTranslated('update_address', context) : getTranslated('save_location', context),
          onPressed:  () {
            List<Branches> branches = Provider.of<SplashProvider>(context, listen: false).configModel!.branches!;
            bool isAvailable = branches.length == 1 && (branches[0].latitude == null || branches[0].latitude!.isEmpty);
            // if(!isAvailable) {
            //   for (Branches branch in branches) {
            //     double distance = Geolocator.distanceBetween(
            //       double.parse(branch.latitude!), double.parse(branch.longitude!),
            //       locationProvider.position.latitude, locationProvider.position.longitude,
            //     ) / 1000;
            //     if (distance < branch.coverage!) {
            //       isAvailable = true;
            //       break;
            //     }
            //   }
            // }
            isAvailable = true;
            if(!isAvailable) {
              showCustomSnackBar(getTranslated('service_is_not_available', context));
            }else {
              AddressModel addressModel = AddressModel(
                addressType: locationProvider.getAllAddressType[locationProvider.selectAddressIndex],
                contactPersonName: contactPersonNameController.text,
                contactPersonNumber: contactPersonNumberController.text.trim().isEmpty ? '' : '${CountryCode.fromCountryCode(countryCode).dialCode}${contactPersonNumberController.text.trim()}',
                address: locationTextController.text ?? '',
                city: city,
                zipcode: zipcode,

                floorNumber: floorNumberController.text,
                houseNumber: houseNumberController.text,
                streetNumber: streetNumberController.text,
              );
              print("this is model ${addressModel.city} AND ${addressModel.zipcode}");
              if (isEnableUpdate) {
                addressModel.id = address!.id;
                addressModel.userId = address!.userId;
                addressModel.method = 'put';
                locationProvider.updateAddress(context, addressModel: addressModel, addressId: addressModel.id).then((value) {});
              } else {
                print("this is model ${addressModel.city} AND ${addressModel.zipcode}");
                locationProvider.addAddress(addressModel, context).then((value) {

                  if (value.isSuccess) {
                    // Navigator.pop(context);
                    if (fromCheckout) {
                      Provider.of<LocationProvider>(context, listen: false).initAddressList();
                      Provider.of<OrderProvider>(context, listen: false).setAddressIndex(-1);
                    } else {
                      showCustomSnackBar(value.message?? '', isError: false);
                    }
                    Navigator.pop(context);
                  } else {
                    showCustomSnackBar(value.message!);
                  }
                });
              }
            }
          },
        ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
      )
    ]);
  }
}