import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/banner_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/wishlist_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/title_row.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/home/widget/all_product_list_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/banners_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/home_item_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  static Future<void> loadData(bool reload, BuildContext context, {bool fromLanguage = false}) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final flashDealProvider = Provider.of<FlashDealProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withLListProvider = Provider.of<WishListProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    ConfigModel config = Provider.of<SplashProvider>(context, listen: false).configModel!;
    if(reload) {
      Provider.of<SplashProvider>(context, listen: false).initConfig();
    }
    if(fromLanguage && (authProvider.isLoggedIn() || config.isGuestCheckout!)) {
      localizationProvider.changeLanguage();
    }
    Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
      context, localizationProvider.locale.languageCode, reload,
    );

    Provider.of<BannerProvider>(context, listen: false).getBannerList(context, reload);


     Provider.of<ProductProvider>(context, listen: false).getItemList(
    '1', true,
      ProductType.dailyItem,
    );
     productProvider.getAllProductList(1, reload, isUpdate: false);


    if(config.mostReviewedProductStatus!) {
       productProvider.getItemList(
       '1', true,
        ProductType.mostReviewed,
      );
    }

    if(config.featuredProductStatus!) {
       productProvider.getItemList(
        '1', true,
        ProductType.featuredItem,
      );
    }



    if(authProvider.isLoggedIn()) {
       withLListProvider.getWishList();
    }

    if(config.flashDealProductStatus!) {
       flashDealProvider.getFlashDealProducts(1, reload, isUpdate: false);
    }

  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            Provider.of<ProductProvider>(context, listen: false).offset = 1;
            Provider.of<ProductProvider>(context, listen: false).popularOffset = 1;
            await HomeScreen.loadData(true, context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Scaffold(
            appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())  : null,
            body: CustomScrollView(controller: scrollController, slivers: [
              SliverToBoxAdapter(child: Center(child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Column(children: [

                  Consumer<BannerProvider>(builder: (context, banner, child) {
                    return banner.bannerList == null ? const BannersView() : banner.bannerList!.isEmpty ? const SizedBox() : const BannersView();
                  }),


                  /// Category
                  Consumer<CategoryProvider>(builder: (context, category, child) {
                    return category.categoryList == null ? const CategoryView() : category.categoryList!.isEmpty ? const SizedBox() : const CategoryView();
                  }),

                  /// Category
                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),

                  /// Flash Deal
                  if(splashProvider.configModel!.flashDealProductStatus!)
                    Consumer<FlashDealProvider>(builder: (context, flashDealProvider, child) {
                      return  flashDealProvider.flashDealModel != null
                          && flashDealProvider.flashDealModel!.products != null
                          && flashDealProvider.flashDealModel!.products!.isEmpty
                          ? const SizedBox() :
                      Column(children: [

                        InkWell(
                          hoverColor: Colors.transparent,
                          onTap: () => Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.flashSale)),
                          child: Container(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            padding: EdgeInsets.only(
                              left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0, top: Dimensions.paddingSizeDefault, bottom: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall,
                            ),
                            child: ResponsiveHelper.isDesktop(context) ? Row(children: [

                              TitleRow(
                                isDetailsPage: false,
                                title: '',
                                eventDuration: flashDealProvider.duration,
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.flashSale)),
                              ),


                              Flexible(child: HomeItemView(productList: flashDealProvider.flashDealModel?.products)),


                            ]) : Column(children: [

                              TitleRow(
                                isDetailsPage: false,
                                title: '',
                                eventDuration: flashDealProvider.duration,
                              ),

                              HomeItemView(productList: flashDealProvider.flashDealModel?.products, isFlashDeal: true),

                              InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.flashSale)),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(
                                      'view_all'.tr,
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor.withOpacity(0.8)),
                                    ),

                                    Icon(
                                      Icons.arrow_forward,
                                      color: Theme.of(context).primaryColor,
                                      size: 15,
                                    ),
                                  ]),
                                ),
                              ),

                            ]),

                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]);
                    }),


                  Consumer<ProductProvider>(builder: (context, productProvider, child) {
                    bool isShowProduct = (productProvider.dailyItemList == null || (productProvider.dailyItemList != null && productProvider.dailyItemList!.isNotEmpty));
                    return isShowProduct ?  Column(children: [
                      TitleWidget(title: getTranslated('daily_needs', context) ,onTap: () {
                        Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.dailyItem));
                      }),

                      HomeItemView(productList: productProvider.dailyItemList),

                    ]) : const SizedBox();
                  }),

                  if(splashProvider.configModel!.featuredProductStatus!) Consumer<ProductProvider>(builder: (context, productProvider, child) {
                    bool isShowProduct = (productProvider.featuredProductList == null || (productProvider.featuredProductList != null && productProvider.featuredProductList!.isNotEmpty));
                    return isShowProduct ? Column(children: [
                      TitleWidget(title: getTranslated(ProductType.featuredItem, context) ,onTap: () {
                        Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.featuredItem));
                      }),

                      HomeItemView(productList: productProvider.featuredProductList, isFeaturedItem: true),
                    ]) : const SizedBox();
                  }),

                  if(splashProvider.configModel!.mostReviewedProductStatus!) Column(children: [
                    TitleWidget(title: getTranslated(ProductType.mostReviewed, context) ,onTap: () {
                      Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.mostReviewed));
                    }),

                    Consumer<ProductProvider>(builder: (context, productProvider, child) {
                      return productProvider.mostViewedProductList == null
                          ? HomeItemView(productList: productProvider.mostViewedProductList)
                          : productProvider.mostViewedProductList!.isEmpty ? const SizedBox()
                          : HomeItemView(productList: productProvider.mostViewedProductList);
                    }),
                  ]),


                  ResponsiveHelper.isMobilePhone() ? const SizedBox(height: 10) : const SizedBox.shrink(),

                  AllProductListView(scrollController: scrollController),

                ]),
              ))),

              if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(height: Dimensions.paddingSizeLarge),

                  FooterView(),
                ]),
              ),


            ]),
          ),
        );
      }
    );
  }
}

