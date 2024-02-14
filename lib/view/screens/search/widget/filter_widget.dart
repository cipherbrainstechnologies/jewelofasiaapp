import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/search_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:provider/provider.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final int? index;

  const FilterWidget({Key? key, required this.maxValue, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : 700,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const SizedBox(),

                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      getTranslated('filter', context),
                      textAlign: TextAlign.center,
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 25, color: Theme.of(context).disabledColor),
                  ),

                ],
              ),
              const SizedBox(height: 15),
              Text(
                getTranslated('price', context),
                style: poppinsMedium,
              ),

              // price range
              RangeSlider(
                values: RangeValues(searchProvider.lowerValue, searchProvider.upperValue),
                max: maxValue!,
                min: 0,
                activeColor: Theme.of(context).primaryColor,
                labels: RangeLabels(searchProvider.lowerValue.toString(), searchProvider.upperValue.toString()),
                onChanged: (RangeValues rangeValues) {
                  searchProvider.setLowerAndUpperValue(rangeValues.start, rangeValues.end);
                },
              ),

              const SizedBox(height: 15),
              Text(
                getTranslated('sort_by', context),
                style: poppinsMedium,
              ),
              const SizedBox(height: 13),
              ListView.builder(
                itemCount: searchProvider.allSortBy.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => InkWell(
                  onTap: () => searchProvider.setFilterIndex(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeSmall,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(2),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: searchProvider.filterIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor.withOpacity(0.6),
                                  width: 2)),
                          child: searchProvider.filterIndex == index
                              ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                        if(!ResponsiveHelper.isDesktop(context))const SizedBox(width: Dimensions.paddingSizeDefault),

                      if(!ResponsiveHelper.isDesktop(context))  Text(
                          searchProvider.allSortBy[index]!,
                          style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                        ),



                        if(ResponsiveHelper.isDesktop(context))
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                        if(ResponsiveHelper.isDesktop(context))  Text(
                          searchProvider.allSortBy[index]!,
                          style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ),

              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Container(height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                        border: Border.all(color: Theme.of(context).disabledColor),
                      ),
                      child: CustomButton(
                        backgroundColor: Theme.of(context).cardColor,
                        textColor: Theme.of(context).disabledColor,
                        buttonText: getTranslated('reset', context),
                        onPressed: () {
                          Provider.of<CategoryProvider>(context, listen: false).updateSelectCategory(-1);
                          searchProvider.setLowerAndUpperValue(0, 0);
                          searchProvider.setFilterIndex(-1);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: SizedBox(height: 45,
                      child: CustomButton(
                        buttonText: getTranslated('apply', context),
                        onPressed: () {
                          Provider.of<SearchProvider>(context, listen: false).sortSearchList();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
