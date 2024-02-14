import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/search_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:flutter_grocery/view/screens/search/widget/filter_widget.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String? searchString;

  const SearchResultScreen({Key? key, this.searchString}) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {

  @override
  void initState() {
    Provider.of<SearchProvider>(context, listen: false).initHistoryList();
    Provider.of<SearchProvider>(context, listen: false).initializeAllSortBy(notify: false);
    Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(widget.searchString, isUpdate: false);
    Provider.of<SearchProvider>(context,listen: false).searchProduct(widget.searchString!, context, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : null,
      body: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Consumer<SearchProvider>(
            builder: (context, searchProvider, child) => SingleChildScrollView(
              child: Column(children: [
                Center(child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height,
                  ),
                  child: SizedBox(width: 1170, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      !ResponsiveHelper.isDesktop(context) ? Row(children: [

                          Flexible(
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                height: 48,
                                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  color: Theme.of(context).disabledColor.withOpacity(0.02),
                                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)),
                                ),
                                child: Row(children: [
                                  Image.asset(Images.search, width: 20, height: 20),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Text(
                                    widget.searchString!,
                                    style: poppinsLight.copyWith(fontSize: Dimensions.paddingSizeLarge),
                                  ),
                                ]),
                              ),
                            ),
                          ),

                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 25),
                        ),

                      ]) : const SizedBox(),
                      const SizedBox(height: 13),

                      Container(
                        height: ResponsiveHelper.isDesktop(context) ? 48 : 60,
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: ColorResources.getAppBarHeaderColor(context),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                searchProvider.searchProductList!=null?
                                Text(
                                  "${searchProvider.searchProductList!.length}",
                                  style: poppinsMedium,
                                ):const SizedBox.shrink(),
                                Text(
                                  '${searchProvider.searchProductList!=null?"":0} ${getTranslated('items_found', context)}',
                                  style: poppinsMedium,
                                ),
                              ],
                            ),
                            searchProvider.searchProductList != null ? InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      List<double?> prices = [];
                                      for (var product in searchProvider.filterProductList!) {
                                        prices.add(product.price);
                                      }
                                      prices.sort();
                                      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;

                                      return Dialog(
                                        insetPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 200 : 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                        child: FilterWidget(maxValue: maxValue),
                                      );
                                    });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                                    vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(color: Theme.of(context).primaryColor)),
                                child: Row(
                                  children: [
                                    ResponsiveHelper.isDesktop(context) ? Text(
                                      getTranslated('filter', context),
                                      style:
                                      poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                    ) : const SizedBox(),
                                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                                    Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                                  ],
                                ),
                              ),
                            ) : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      //const SizedBox(height: 22),

                      searchProvider.searchProductList != null ? searchProvider.searchProductList!.isNotEmpty ?
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                          childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : (1/1.7),
                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 2,
                        ),
                        itemCount: searchProvider.searchProductList!.length,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) => ProductWidget(
                          product: searchProvider.searchProductList![index],
                          productType: ProductType.searchItem,
                          isGrid: true,
                          isCenter: true,
                        ),

                      ) : NoDataScreen(isFooter: false, title: getTranslated('not_product_found', context),) :
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                          childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : (1/1.7),
                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 2,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) => WebProductShimmer(isEnabled: searchProvider.searchProductList == null),
                      ),
                    ],
                  )),
                )),

                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
              ]),
            ),
          )),
      ),
    );
  }
}
