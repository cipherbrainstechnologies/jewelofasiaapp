import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/wishlist_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()? null: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : const AppBarBase()) as PreferredSizeWidget?,
      body: _isLoggedIn ? Consumer<WishListProvider>(
        builder: (context, wishlistProvider, child) {
          if(wishlistProvider.isLoading) {
           return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
          }
          return wishlistProvider.wishList != null ? wishlistProvider.wishList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await Provider.of<WishListProvider>(context, listen: false).getWishList();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1, vertical:  Dimensions.paddingSizeDefault),
                        child: SizedBox(
                          width: 1170,
                          child:  Column(
                            children: [

                              ResponsiveHelper.isDesktop(context) ? Padding(
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                                child: Text("favourite_list".tr, style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              ) : const SizedBox(),

                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.41) : (1/1.6),
                                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 2),
                                itemCount: wishlistProvider.wishList!.length,
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ProductWidget(product: wishlistProvider.wishList![index], isGrid: true, isCenter: true);
                                },
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ),
                  if(ResponsiveHelper.isDesktop(context)) const FooterView(),
                ],
              ),
            ),
          ): NoDataScreen(title: getTranslated('not_product_found', context), image: Images.favouriteNoDataImage) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ) : const NotLoggedInScreen(),
    );
  }
}
