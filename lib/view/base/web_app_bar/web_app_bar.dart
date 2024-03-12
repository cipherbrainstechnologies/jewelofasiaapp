import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/data/model/response/language_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/language_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/search_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/provider/wishlist_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_dialog.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:flutter_grocery/view/base/web_app_bar/widget/language_hover_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/widget/profile_hover_view.dart';
import 'package:flutter_grocery/view/screens/search/search_result_screen.dart';
import 'package:flutter_grocery/view/screens/settings/widget/currency_dialog.dart';
import 'package:provider/provider.dart';

import '../../screens/home/web/category_hover_widget.dart';
import '../custom_text_field.dart';

enum PopupMenuType{ language, category, profile}

class WebAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBar({Key? key}) : super(key: key);


  @override
  State<WebAppBar> createState() => _WebAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarState extends State<WebAppBar> {
  String? chooseLanguage;
  
  List<PopupMenuEntry<Object>> popUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> list = <PopupMenuEntry<Object>>[];
    List<CategoryModel>? categoryList =  Provider.of<CategoryProvider>(context, listen: false).categoryList;
    list.add(
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          value: categoryList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: CategoryHoverWidget(categoryList: categoryList),
          ),
        ));
    return list;
  }

  List<PopupMenuEntry<Object>> popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList =  AppConstants.languages;
    languagePopupMenuEntryList.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: languageList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: LanguageHoverWidget(languageList: languageList),
          ),
        ));
    return languagePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> profilePopUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> profilePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    profilePopupMenuEntryList.add(
        const PopupMenuItem(
          padding: EdgeInsets.zero,
          child: MouseRegion(
            child: ProfileHoverView(),
          ),
        ));
    return profilePopupMenuEntryList;
  }

  List<PopupMenuEntry<Object>> _getPopupItems(PopupMenuType type){
    switch (type) {
      case PopupMenuType.language:
        return popUpLanguageList(context);
      case PopupMenuType.category:
        return popUpMenuList(context);
      case PopupMenuType.profile:
        return profilePopUpMenuList(context);
    }
  }

  _showPopupMenu(Offset offset, BuildContext context, PopupMenuType type) async {
    double left = offset.dx;
    double top = offset.dy;
    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          left, top, overlay.size.width, overlay.size.height),
      items: _getPopupItems(type),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),

    );
  }

  @override
  void initState() {

    // _loadData(context, true);

    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider =  Provider.of<ThemeProvider>(context, listen: false);
    Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    LanguageModel currentLanguage = AppConstants.languages.firstWhere((language) => language.languageCode == Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0,10),
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            color: ColorResources.getAppBarHeaderColor(context),
            height: 45,
            child: Center(
              child: SizedBox( width: 1170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text('dark_mode'.tr, style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.paddingSizeDefault)),
                      ),
                      // StatusWidget(),
                      Transform.scale(
                        scale: 0.6,
                        child: Switch(
                          onChanged: (bool isActive) => themeProvider.toggleTheme(),
                          value: themeProvider.darkTheme,
                          activeColor: Colors.black26,
                          activeTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Theme.of(context).primaryColor,

                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      // SizedBox(
                      //   height: Dimensions.paddingSizeLarge,
                      //
                      //   child: MouseRegion(
                      //     onHover: (details){
                      //       _showPopupMenu(details.position, context, PopupMenuType.language);
                      //     },
                      //     child: InkWell(
                      //       onTap: () => showAnimatedDialog(context, const CurrencyDialog()),
                      //       // onTap: () => Navigator.pushNamed(context, RouteHelper.getLanguageRoute('menu')),
                      //       child: Row(
                      //         children: [
                      //           Text('${currentLanguage.languageCode?.toUpperCase()}',style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                      //           const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      //           Icon(Icons.expand_more, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(color: Theme.of(context).cardColor,
              child: Center(
                child: SizedBox(
                    width: 1170,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(children: [
                          InkWell(
                            onTap: () {
                              Provider.of<ProductProvider>(context, listen: false).offset = 1;
                              if(ModalRoute.of(context)!.settings.name != RouteHelper.getMainRoute()) {
                                Navigator.pushNamed(context, RouteHelper.getMainRoute());
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(height: 50,
                                    child: Consumer<SplashProvider>(
                                      builder:(context, splash, child) => CustomImage(
                                        placeholder: Images.webBarLogoPlaceHolder,
                                        image: splash.baseUrls != null ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.ecommerceLogo}' : '',
                                        fit: BoxFit.contain,
                                        width: 115,
                                      ),
                                    )),

                              ],
                            ),
                          ),
                          const SizedBox(width: 30),

                          TextHover(builder: (isHovered) {
                            return InkWell(
                              onTap: () {
                                Provider.of<ProductProvider>(context, listen: false).offset = 1;
                                if(ModalRoute.of(context)!.settings.name != RouteHelper.getMainRoute()) {
                                  Navigator.pushNamed(context, RouteHelper.getMainRoute());
                                }
                              },
                              child: Text('home'.tr, style: isHovered ?
                              poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeLarge) :
                              poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: Dimensions.fontSizeLarge)),
                            );
                          }),
                          const SizedBox(width: 30),

                          TextHover(
                            builder: (isHovered) {
                              return MouseRegion(onHover: (details){
                                if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null){
                                  _showPopupMenu(details.position, context, PopupMenuType.category);
                                }

                              },
                                child: Row(children: [

                                  Text('categories'.tr,
                                      style: isHovered ? poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge) :
                                        poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: Dimensions.fontSizeLarge),
                                    ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Icon(Icons.expand_more, color: Theme.of(context).primaryColor, size: 20),

                                ]),
                              );
                            }),
                        ]),


                        Row(children: [
                          Container(
                            width: 500,
                            decoration: BoxDecoration(
                              color:  Theme.of(context).disabledColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 2),
                            child: Consumer<SearchProvider>(
                                builder: (context,search,_) {
                                  return CustomTextField(
                                    hintText: getTranslated('search_for_products', context),
                                    isShowBorder: false,
                                    fillColor: Colors.transparent,
                                    isElevation: false,
                                    isShowSuffixIcon: true,
                                    imageColor: Theme.of(context).primaryColor,
                                    suffixAssetUrl: !search.isSearch ? Images.close : Images.search,
                                    onChanged: (str){
                                      str.length = 0;
                                      search.getSearchText(str);
                                      },

                                    onSuffixTap: () {
                                      if(search.searchController.text.isNotEmpty && search.isSearch == true){

                                        Navigator.pushNamed(context, RouteHelper.getSearchResultRoute(search.searchController.text),
                                            arguments: SearchResultScreen(searchString: search.searchController.text));
                                        search.searchDone();
                                      }
                                      else if (search.searchController.text.isNotEmpty && search.isSearch == false) {
                                        search.searchController.clear();
                                        search.getSearchText('');
                                        search.searchDone();
                                      }
                                    },
                                    controller: search.searchController,
                                    inputAction: TextInputAction.search,
                                    isIcon: true,
                                    onSubmit: (text) {
                                      if (search.searchController.text.isNotEmpty) {

                                        Navigator.pushNamed(context, RouteHelper.getSearchResultRoute(search.searchController.text));

                                        search.searchDone();
                                      }

                                    },);
                                }
                            ),
                          ),
                          const SizedBox(width: 70),


                          OnHover(child: InkWell(
                            onTap: () => Navigator.pushNamed(context, RouteHelper.favorite),
                            child: Consumer<WishListProvider>(builder: (context, wishListProvider, _)=> CountView(
                              count: wishListProvider.wishList?.length ?? 0, icon: Icons.favorite,
                            )),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                          OnHover(child: InkWell(
                            onTap: () => Navigator.pushNamed(context, RouteHelper.cart),
                            child: Consumer<CartProvider>(builder: (context, cartProvider, _)=> CountView(
                              count: cartProvider.cartList.length, icon: Icons.shopping_cart,
                            )),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                          Consumer<AuthProvider>(builder: (context, authProvider, _)=> InkWell(
                            onTap: () => !authProvider.isLoggedIn() ? Navigator.pushNamed(context, RouteHelper.login) : (){},
                            child: TextHover(builder: (isHover)=> OnHover(child: MouseRegion(
                              onHover: (details){
                                if(authProvider.isLoggedIn()) {
                                  _showPopupMenu(details.position, context, PopupMenuType.profile);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                child: authProvider.isLoggedIn() ? Consumer<ProfileProvider>(
                                  builder: (context, profileProvider, _) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                      child: CustomImage(
                                        image: '${splashProvider.baseUrls!.customerImageUrl}/${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.image : ''}',
                                        placeholder: Images.profile,
                                        height: 32,
                                        width: 32,
                                      ),
                                    );
                                  }
                                ) : Icon(
                                  Icons.person, size: Dimensions.paddingSizeExtraLarge,
                                  color: isHover ? Theme.of(context).primaryColor : Theme.of(context).focusColor,
                                ),
                              )))),

                          )),

                          const SizedBox(width: Dimensions.paddingSizeExtraLarge),

                          IconButton(
                            onPressed: () => Navigator.pushNamed(context, RouteHelper.profileMenus),
                            icon: Icon(Icons.menu,size: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                          ),
                        ]),
                      ],
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Size get preferredSize => const Size(double.maxFinite, 160);
}

class CountView extends StatelessWidget {
  final int count;
  final IconData icon;
  const CountView({
    Key? key, required this.count, required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (isHover)=> Stack(clipBehavior: Clip.none, children: [
      Icon(icon, color: isHover ? Theme.of(context).primaryColor : Theme.of(context).focusColor,
        size: Dimensions.paddingSizeExtraLarge,
      ),

      if(count > 0) Positioned(top: -15, right: -10, child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).cardColor, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text('$count',style: poppinsRegular.copyWith(
            color: Colors.white,
            fontSize: Dimensions.fontSizeExtraSmall,
          )),
        ),
      )),
    ]));
  }
}
