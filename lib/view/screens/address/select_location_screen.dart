import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/address_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/screens/address/widget/location_search_dialog.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final GoogleMapController? googleMapController;
  const SelectLocationScreen({Key? key, required this.googleMapController}) : super(key: key);

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? _controller;
  final TextEditingController _locationController = TextEditingController();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition = LatLng(
      double.parse(Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0].latitude! ),
      double.parse(Provider.of<SplashProvider>(context, listen: false).configModel!.branches![0].longitude!),
    );
    Provider.of<LocationProvider>(context, listen: false).setPickData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _openSearchDialog(BuildContext context, GoogleMapController? mapController) async {
    showDialog(context: context, builder: (context) => LocationSearchDialog(mapController: mapController));
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<LocationProvider>(context).address != null) {
      _locationController.text = Provider.of<LocationProvider>(context).address ?? '';
    }

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): CustomAppBar(title: getTranslated('select_delivery_address', context), isCenter: true)) as PreferredSizeWidget?,
      body: Center(
        child: SizedBox(
          width: 1170,
          child: Consumer<LocationProvider>(
            builder: (context, locationProvider, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                GoogleMap(
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: true,
                  onCameraIdle: () {
                    locationProvider.updatePosition(_cameraPosition, false, null,false);
                  },
                  onCameraMove: ((position) => _cameraPosition = position),
                  // markers: Set<Marker>.of(locationProvider.markers),
                  onMapCreated: (GoogleMapController controller) {
                    Future.delayed(const Duration(milliseconds: 800)).then((value) {
                      _controller = controller;
                      _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                          target:  locationProvider.pickPosition.longitude.toInt() == 0 &&  locationProvider.pickPosition.latitude.toInt() == 0 ? _initialPosition : LatLng(
                        locationProvider.pickPosition.latitude, locationProvider.pickPosition.longitude,
                      ), zoom: 15)));
                    });

                  },
                ),
                locationProvider.pickAddress != null
                    ? SearchBarView(onTap: ()=> _openSearchDialog(context, _controller))
                    : const SizedBox.shrink(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => AddressHelper.checkPermission((){
                          locationProvider.getCurrentLocation(context, false, mapController: _controller);
                        }),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: Theme.of(context).primaryColor,
                            size: 35,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: CustomButton(
                            buttonText: getTranslated('select_location', context),
                            onPressed: locationProvider.loading ? null : () {
                              if(widget.googleMapController != null) {
                                widget.googleMapController!.setMapStyle('[]');
                                widget.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
                                  locationProvider.pickPosition.latitude, locationProvider.pickPosition.longitude,
                                ), zoom: 16)));

                                if(ResponsiveHelper.isWeb()) {
                                  locationProvider.setAddAddressData(true);
                                }
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 50,
                    )),
                locationProvider.loading
                    ? Center(child: CustomLoader(color: Theme.of(context).primaryColor))
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBarView extends StatelessWidget {
  final Function onTap;
  final double margin;
  const SearchBarView({
    Key? key, required this.onTap, this.margin = Dimensions.paddingSizeExtraLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return InkWell(
      onTap: ()=> onTap(),
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
          margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: margin),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
          child: Row(children: [
            Expanded(child: Text(
              locationProvider.pickAddress != null && locationProvider.pickAddress!.isNotEmpty
                  ? locationProvider.pickAddress! :  getTranslated('search_here', context),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )),

            Icon(Icons.search, size: Dimensions.paddingSizeExtraLarge, color: Theme.of(context).primaryColor),
          ]),
        ),
    );
  }
}
