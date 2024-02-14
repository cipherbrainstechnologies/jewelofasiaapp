import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/base/paginated_list_view.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:provider/provider.dart';

class AllProductListView extends StatefulWidget {
  const AllProductListView({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  State<AllProductListView> createState() => _AllProductListViewState();
}

class _AllProductListViewState extends State<AllProductListView> {
  ProductFilterType filterType = ProductFilterType.latest;

  @override
  Widget build(BuildContext context) {
    ConfigModel config = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleWidget(title: getTranslated('all_items', context)),

              PopupMenuButton<ProductFilterType>(
                padding: const EdgeInsets.all(0),
                onSelected: (ProductFilterType result) {
                  filterType = result;
                  productProvider.getAllProductList(1, true, type: result);
                },
                itemBuilder: (BuildContext c) => <PopupMenuEntry<ProductFilterType>>[
                  PopupMenuItem<ProductFilterType>(
                    value: ProductFilterType.latest,
                    child: PopUpItem(title: getTranslated('latest_items', context)),
                  ),

                  PopupMenuItem<ProductFilterType>(
                    value: ProductFilterType.popular,
                    child: PopUpItem(title: getTranslated('popular_items', context)),
                  ),

                 if(config.recommendedProductStatus!) PopupMenuItem<ProductFilterType>(
                    value: ProductFilterType.recommended,
                    child: PopUpItem(title: getTranslated('recommend_items', context)),
                  ),

                 if(config.trendingProductStatus!) PopupMenuItem<ProductFilterType>(
                    value: ProductFilterType.trending,
                    child: PopUpItem(title: getTranslated('trending_items', context)),
                  ),

                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  margin: EdgeInsets.only(right: ResponsiveHelper.isDesktop(context) ? 0 :Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                    size: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                  ),
                ),
              ),
            ],
          ),

          PaginatedListView(
            onPaginate: (int? offset) async => await productProvider.getAllProductList(offset!, false),
            offset: productProvider.allProductModel?.offset,
            totalSize: productProvider.allProductModel?.totalSize,
            limit: productProvider.allProductModel?.limit,
            scrollController: widget.scrollController,
            itemView: Column(children: [

              (productProvider.allProductModel != null && productProvider.allProductModel != null &&  productProvider.allProductModel!.products!.isEmpty) ?  NoDataScreen(
                isFooter: false, title: getTranslated('not_product_found', context),
              ) : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                  mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : (1/1.6),
                  crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 2,
                ),
                itemCount: productProvider.allProductModel?.products != null ? productProvider.allProductModel?.products?.length : 10,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall,
                  vertical: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return productProvider.allProductModel?.products != null ?  ProductWidget(
                    product: productProvider.allProductModel!.products![index],
                    isCenter: true, isGrid: true,
                  ) : WebProductShimmer(isEnabled: productProvider.allProductModel == null);
                },
              ),

            ]),
          ),
        ]);
      }
    );
  }
}

class PopUpItem extends StatelessWidget {
  final String title;
  const PopUpItem({
    Key? key, required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnHover(child: Text(title, style: poppinsMedium));
  }
}
