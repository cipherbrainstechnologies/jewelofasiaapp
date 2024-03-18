// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? mapController;

  const LocationSearchDialog({Key? key, required this.mapController})
      : super(key: key);

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  List<Prediction> suggestions = [];

  @override
  Widget build(BuildContext context) {
     final TextEditingController controller = TextEditingController();

    return Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSizeDefault)),
              margin: EdgeInsets.only(
                top: ResponsiveHelper.isDesktop(context) ? 160 : 75,
                right: Dimensions.paddingSizeSmall,
                left: Dimensions.paddingSizeSmall,
              ),
              alignment: Alignment.topCenter,
              child: SizedBox(
                  width: 650,
                  child: Column(
                    children: [
                    TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (pattern) {
                      Provider.of<LocationProvider>(context,
                          listen: false)
                          .searchLocation(context, pattern)
                          .then((value) => setState(() {
                        suggestions = value;
                      }));
                    },
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      hintText:
                      getTranslated('search_location', context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            style: BorderStyle.none, width: 0),
                      ),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).disabledColor,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),

                        child: ListView.builder(
                          shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                            Provider.of<LocationProvider>(context, listen: false)
                                .setLocation(suggestions[index].placeId,
                                suggestions[index].description, widget.mapController);
                              Navigator.pop(context);
    },
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              child: Row(children: [
                                const Icon(Icons.location_on),
                                Expanded(
                                  child: Text(suggestions[index].description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                            fontSize: Dimensions.fontSizeLarge,
                                          )),
                                ),
                              ]),
                            ),
                          );
                        }),
                      )
                    ],
                  )),
            );
  }
}
