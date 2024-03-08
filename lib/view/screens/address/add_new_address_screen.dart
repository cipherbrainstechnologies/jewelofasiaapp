
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/address_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/address/select_location_screen.dart';
import 'package:flutter_grocery/view/screens/address/widget/buttons_view.dart';
import 'package:flutter_grocery/view/screens/address/widget/details_view.dart';
import 'package:flutter_grocery/view/screens/address/widget/location_search_dialog.dart';
import 'package:flutter_grocery/view/screens/auth/widget/country_code_picker_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  const AddNewAddressScreen({Key? key, this.isEnableUpdate = true, this.address, this.fromCheckout = false}) : super(key: key);

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {

  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _florNumberController = TextEditingController();

  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _stateNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();


  String? countryCode;


  _initLoading() async {
    countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.country!).code;

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    final userModel =  Provider.of<ProfileProvider>(context, listen: false).userInfoModel ;
    if(widget.address == null) {
      locationProvider.setAddAddressData(false);
    }


    await locationProvider.initializeAllAddressType(context: context);
    locationProvider.updateAddressStatusMessage(message: '');
    locationProvider.updateErrorMessage(message: '');

    if (widget.isEnableUpdate && widget.address != null) {
      String? code = CountryPick.getCountryCode('${widget.address!.contactPersonNumber}');
      if(code != null){
        countryCode =  CountryCode.fromDialCode(code).code;
      }

      locationProvider.isUpdateAddress = false;

      locationProvider.updatePosition(
        CameraPosition(target: LatLng(double.parse(widget.address!.latitude!),
          double.parse(widget.address!.longitude!))), true, widget.address!.address, false,
      );
      _contactPersonNameController.text = '${widget.address!.contactPersonName}';
      _contactPersonNumberController.text = '${widget.address!.contactPersonNumber}';
      _streetNumberController.text = widget.address!.streetNumber ?? '';
      _houseNumberController.text = widget.address!.houseNumber ?? '';
      _florNumberController.text = widget.address!.floorNumber ?? '';

      if (widget.address!.addressType == 'Home') {
        locationProvider.updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        locationProvider.updateAddressIndex(1, false);
      } else {
        locationProvider.updateAddressIndex(2, false);
      }
    }else {
      if(authProvider.isLoggedIn()){
        String? code = CountryPick.getCountryCode(userModel?.phone);

        if(code != null){
          countryCode = CountryCode.fromDialCode(code).code;
        }
        _contactPersonNameController.text = userModel == null ? '' : '${userModel.fName}' ' ${userModel.lName}';
        _contactPersonNumberController.text = (code != null ? (userModel?.phone ?? '').replaceAll(code, '') : userModel?.phone ?? '');
      }
    }


  }

  @override
  void initState() {
    super.initState();

    _initLoading();

    if(widget.address != null && !widget.fromCheckout) {
      Provider.of<LocationProvider>(context, listen: false).setAddress = widget.address?.address;
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())
          : CustomAppBar(title: widget.isEnableUpdate
          ? getTranslated('update_address', context)
          : getTranslated('add_new_address', context),
      )) as PreferredSizeWidget?,

      body: Consumer<LocationProvider>(builder: (context, locationProvider, child) {
        return Column(children: [
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if(!ResponsiveHelper.isDesktop(context)) MapViewSection(
                    isEnableUpdate: widget.isEnableUpdate,
                    fromCheckout: widget.fromCheckout,
                  ),

                  // for label us
                  if(!ResponsiveHelper.isDesktop(context)) DetailsView(
                    contactPersonNameController: _contactPersonNameController,
                    contactPersonNumberController: _contactPersonNumberController,
                    addressNode: _addressNode, nameNode: _nameNode,
                    numberNode: _numberNode, fromCheckout: widget.fromCheckout,
                    address: widget.address, isEnableUpdate: widget.isEnableUpdate,
                    streetNumberController: _streetNumberController,
                    houseNumberController: _houseNumberController,
                    houseNode: _houseNode,
                    stateNode: _stateNode,
                    florNumberController: _florNumberController,
                    florNode: _floorNode,
                    countryCode: countryCode!,
                    onValueChange: (code){
                      countryCode = code;
                    },
                  ),


                  if(ResponsiveHelper.isDesktop(context)) IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex : 6, child: MapViewSection(
                          isEnableUpdate: widget.isEnableUpdate,
                          fromCheckout: widget.fromCheckout,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(flex: 4, child: DetailsView(
                          contactPersonNameController: _contactPersonNameController,
                          contactPersonNumberController: _contactPersonNumberController,
                          addressNode: _addressNode, nameNode: _nameNode,
                          numberNode: _numberNode, isEnableUpdate: widget.isEnableUpdate,
                          address: widget.address, fromCheckout: widget.fromCheckout,
                          streetNumberController: _streetNumberController,
                          houseNumberController: _houseNumberController,
                          houseNode: _houseNode,
                          stateNode: _stateNode,
                          florNumberController: _florNumberController,
                          florNode: _floorNode,
                          countryCode: countryCode!,
                          onValueChange: (code){
                            countryCode = code;
                          },
                        )),
                      ],
                    ),
                  ),

                ],
              ))),
            )),

            if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
              hasScrollBody: false,
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                SizedBox(height: Dimensions.paddingSizeLarge),

                FooterView(),
              ]),
            ),

          ])),

          if(!ResponsiveHelper.isDesktop(context)) ButtonsView(
            isEnableUpdate: widget.isEnableUpdate,
            fromCheckout: widget.fromCheckout,
            contactPersonNumberController:
            _contactPersonNumberController,
            contactPersonNameController: _contactPersonNameController,
            address: widget.address,
            streetNumberController: _streetNumberController,
            houseNumberController: _houseNumberController,
            floorNumberController: _florNumberController,
            countryCode: countryCode!,
          ),
        ]);
      }),
    );
  }

}

class MapViewSection extends StatelessWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;

  const MapViewSection({
    Key? key,
    required this.isEnableUpdate,
    required this.fromCheckout,
    this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ?  BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:ColorResources.cartShadowColor.withOpacity(0.2),
            blurRadius: 10,
          )
        ],
      ) : const BoxDecoration(),

      padding: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge,
      ) : EdgeInsets.zero,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // if(ResponsiveHelper.isDesktop(context)) Expanded(child: MapWidget(
          //   fromCheckout: fromCheckout,
          //   isEnableUpdate: isEnableUpdate,
          //   address: address,
          // )),

          // if(!ResponsiveHelper.isDesktop(context)) MapWidget(
          //   fromCheckout: fromCheckout,
          //   isEnableUpdate: isEnableUpdate,
          //   address: address,
          // ),
          //
          // Padding(padding: const EdgeInsets.only(top: 10), child: Center(child: Text(
          //   getTranslated('add_the_location_correctly', context),
          //   style: poppinsRegular.copyWith(
          //     color: Theme.of(context).textTheme.bodyLarge!.color,
          //     fontSize: Dimensions.fontSizeSmall,
          //   ),
          // ))),

          Padding(padding: const EdgeInsets.symmetric(vertical: 24.0), child: Text(
            getTranslated('label_us', context),
            style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge,
            ),
          )),

          SizedBox(height: 50, child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: locationProvider.getAllAddressType.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                locationProvider.updateAddressIndex(index, true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                margin: const EdgeInsets.only(right: 17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  border: Border.all(color: locationProvider.selectAddressIndex == index
                      ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.6)
                  ),
                  color: locationProvider.selectAddressIndex == index
                      ? Theme.of(context).primaryColor : Theme.of(context).cardColor.withOpacity(0.9),
                ),
                child: Text(
                  getTranslated(locationProvider.getAllAddressType[index].toLowerCase(), context),
                  style: poppinsRegular.copyWith(
                    color: locationProvider.selectAddressIndex == index
                        ? Theme.of(context).cardColor
                        : Theme.of(context).hintColor.withOpacity(0.6),
                  ),

                ),
              ),
            ),
          )),

        ],
      ),
    );
  }
}



class MapWidget extends StatelessWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;

  const MapWidget({
    Key? key, required this.isEnableUpdate, this.address, required this.fromCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);

    final branch = Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0];

    return SizedBox(
      height: ResponsiveHelper.isMobile() ? 130 : 250,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        child: Stack(
          clipBehavior: Clip.none, children: [
          GoogleMap(
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: isEnableUpdate ? LatLng(
                double.parse( address != null ? address!.latitude! : branch.latitude!),
                double.parse( address != null ? address!.longitude! : branch.longitude!),
              ) : LatLng(locationProvider.position.latitude.toInt()  == 0
                  ? double.parse(branch.latitude!)
                  : locationProvider.position.latitude, locationProvider.position.longitude.toInt() == 0
                  ? double.parse(branch.longitude!)
                  : locationProvider.position.longitude,
              ),
              zoom: 8,
            ),
            zoomControlsEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: true,
            mapToolbarEnabled: false,
            onCameraIdle: () {
              if(address != null && !fromCheckout) {
                locationProvider.updatePosition(locationProvider.cameraPosition, true, null, true);
                locationProvider.isUpdateAddress = true;
              }else {
                if(locationProvider.isUpdateAddress) {
                  locationProvider.updatePosition(locationProvider.cameraPosition, true, null, true);
                }else {
                  locationProvider.isUpdateAddress = true;
                }
              }

            },
            onCameraMove: ((position) => locationProvider.cameraPosition = position),
            onMapCreated: (GoogleMapController controller) {
              locationProvider.mapController = controller;

              if (!isEnableUpdate && locationProvider.mapController != null) {

                AddressHelper.checkPermission(()=>locationProvider.getCurrentLocation(
                  context, true, mapController: locationProvider.mapController,
                ));
              }
            },
          ),
          locationProvider.loading ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              )) : const SizedBox(),

          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child:Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 35,
              )
          ),

          Positioned(
            bottom: 10,
            right: 0,
            child: InkWell(
              onTap: () => AddressHelper.checkPermission(()=>locationProvider.getCurrentLocation(
                context, true, mapController: locationProvider.mapController,
              )),
              child: Container(
                width: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.my_location,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),

          if(ResponsiveHelper.isDesktop(context)) Positioned.fill(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 500,
                child: SearchBarView(margin: Dimensions.paddingSizeSmall, onTap: (){
                  showDialog(context: context, builder: (context) => Container(
                    width: 600,
                    margin: const EdgeInsets.only(right:  480),
                    child: LocationSearchDialog(mapController: locationProvider.mapController),
                  ), barrierDismissible: true);
                }),
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 0,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context, RouteHelper.getSelectLocationRoute(),
                  arguments: SelectLocationScreen(googleMapController: locationProvider.mapController),
                );
              },
              child: Container(
                width: ResponsiveHelper.isDesktop(context) ? 55 : 30,
                height: ResponsiveHelper.isDesktop(context) ? 55 : 30,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  color: Theme.of(context).cardColor,
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: Theme.of(context).primaryColor,
                  size: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge,
                ),
              ),
            ),
          ),

        ]),
      ),
    );
  }
}






