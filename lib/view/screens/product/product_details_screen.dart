import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/custom_zoom_widget.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/base/wish_button.dart';
import 'package:flutter_grocery/view/screens/product/widget/details_app_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/product_image_view.dart';
import 'package:flutter_grocery/view/screens/product/widget/product_title_view.dart';
import 'package:flutter_grocery/view/screens/product/widget/rating_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/variation_view.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'widget/product_review.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final bool? fromSearch;
  const ProductDetailsScreen({Key? key, required this.productId, this.fromSearch = false}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>  with TickerProviderStateMixin {
  int _tabIndex = 0;
  bool showSeeMoreButton = true;

  @override
  void initState() {

    Provider.of<ProductProvider>(context, listen: false).getProductDetails('${widget.productId}', searchQuery: widget.fromSearch!);
    Provider.of<CartProvider>(context, listen: false).getCartData();
    Provider.of<CartProvider>(context, listen: false).setSelect(0, false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Variations? variation;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())  : DetailsAppBar(key: UniqueKey(), title: 'product_details'.tr),

      body: Consumer<CartProvider>(builder: (context, cart, child) {
        return  Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            double? price = 0;
            int? stock = 0;
            double? priceWithQuantity = 0;
            CartModel? cartModel;

            if(productProvider.product != null) {
              List<String> variationList = [];
              for (int index = 0; index < productProvider.product!.choiceOptions!.length; index++) {
                variationList.add(productProvider.product!.choiceOptions![index].options![productProvider.variationIndex![index]].replaceAll(' ', ''));
              }
              String variationType = '';
              bool isFirst = true;
              for (var variation in variationList) {
                if (isFirst) {
                  variationType = '$variationType$variation';
                  isFirst = false;
                } else {
                  variationType = '$variationType-$variation';
                }
              }
              price = productProvider.product!.price;
              stock = productProvider.product!.totalStock;
              print("total stock is ${productProvider.product!.totalStock} ${productProvider.product!.price}");

              for (Variations variationData in productProvider.product!.variations!) {
                if (variationData.type == variationType) {
                  price = variationData.price;
                  variation = variationData;
                stock = variationData.stock;
                print("variationData stock is ${variationData.stock}");
                  break;
                }
              }
              double? priceWithDiscount = 0;
              double? categoryDiscountAmount;
              if(productProvider.product!.categoryDiscount != null) {
               categoryDiscountAmount = PriceConverter.convertWithDiscount(
                 price, productProvider.product!.categoryDiscount!.discountAmount, productProvider.product!.categoryDiscount!.discountType,
                 maxDiscount: productProvider.product!.categoryDiscount!.maximumAmount,
               );
              }
              priceWithDiscount = PriceConverter.convertWithDiscount(price, productProvider.product!.discount, productProvider.product!.discountType);

              if(categoryDiscountAmount != null && categoryDiscountAmount > 0
                  && categoryDiscountAmount  < priceWithDiscount!) {
                priceWithDiscount = categoryDiscountAmount;
              }


              cartModel = CartModel(
                productProvider.product!.id, productProvider.product!.image!.isNotEmpty
                  ? productProvider.product!.image![0] : '',
                  productProvider.product!.name,  price,
                priceWithDiscount,
                productProvider.quantity, variation,
                (price! - priceWithDiscount!),
                (price- PriceConverter.convertWithDiscount(price, productProvider.product!.tax, productProvider.product!.taxType)!),
                  productProvider.product!.capacity, productProvider.product!.unit, stock,productProvider.product
              );


              productProvider.setExistData(Provider.of<CartProvider>(context).isExistInCart(cartModel));


              try{
                priceWithQuantity = priceWithDiscount * (productProvider.cartIndex != null ? cart.cartList[productProvider.cartIndex!].quantity! : productProvider.quantity);
              }catch (e){
                priceWithQuantity = priceWithDiscount;
              }
            }

            return productProvider.product != null ?
            !ResponsiveHelper.isDesktop(context) ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ResponsiveHelper.isMobilePhone()? const BouncingScrollPhysics():null,
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(children: [
                              ProductImageView(productModel: productProvider.product),

                              SizedBox(height: 60, child: productProvider.product!.image != null ? SelectedImageWidget(productModel: productProvider.product) : const SizedBox(),),

                              ProductTitleView(product: productProvider.product, stock: stock, cartIndex: productProvider.cartIndex),

                              VariationView(product: productProvider.product),

                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Row(mainAxisAlignment : MainAxisAlignment.spaceBetween, children: [

                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    CustomDirectionality(child: Text(
                                      PriceConverter.convertPrice(context, priceWithQuantity),
                                      style: poppinsBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                      ),
                                    )),
                                  ]),

                                  Builder(
                                    builder: (context) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).disabledColor.withOpacity(0.07),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                                        ),

                                        child: Row(children: [
                                          QuantityButton(
                                            isIncrement: false, quantity: productProvider.quantity,
                                            stock: stock, cartIndex: productProvider.cartIndex,
                                            maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                          ),
                                          const SizedBox(width: 15),

                                          Consumer<CartProvider>(builder: (context, cart, child) {
                                            return Text(productProvider.cartIndex != null ? cart.cartList[productProvider.cartIndex!].quantity.toString()
                                                : productProvider.quantity.toString(), style: poppinsBold.copyWith(color: Theme.of(context).primaryColor)
                                            );
                                          }),
                                          const SizedBox(width: 15),

                                          QuantityButton(
                                            isIncrement: true, quantity: productProvider.quantity,
                                            stock: stock, cartIndex: productProvider.cartIndex,
                                            maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                          ),
                                        ]),
                                      );
                                    }
                                  ),

                                ]),
                              ),
                            ],),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            _description(context, productProvider),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Center(child: SizedBox(width: 1170, child: CustomButton(
                  icon: Icons.shopping_cart,
                  margin: Dimensions.paddingSizeSmall,
                  buttonText: getTranslated(productProvider.cartIndex != null ? 'already_added' : stock! <= 0 ? 'out_of_stock' : 'add_to_card', context),
                  onPressed: (productProvider.cartIndex == null && stock! > 0) ? () {
                    if(cart.cartList.isEmpty){
                      if (productProvider.cartIndex == null && stock! > 0) {
                        Provider.of<CartProvider>(context, listen: false)
                            .addToCart(cartModel!);
                        showCustomSnackBar(
                            getTranslated('added_to_cart', context),
                            isError: false);
                      } else {
                        showCustomSnackBar(
                            getTranslated('already_added', context));
                      }
                    }else {
                      if (cart.cartList
                          .where((element) =>
                      element.product!.isSubscriptionProduct == 0)
                          .isEmpty &&
                          cartModel!.product!.isSubscriptionProduct == 1) {

                        if(cart.cartList.where((element) => element.id == cartModel!.product!.id).isNotEmpty) {
                          if (productProvider.cartIndex == null && stock! > 0) {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(cartModel);
                            showCustomSnackBar(
                                getTranslated('added_to_cart', context),
                                isError: false);
                          } else {
                            showCustomSnackBar(
                                getTranslated('already_added', context));
                          }
                        }else{
                          showCustomSnackBar("you can not choose more then one subscription product at a time.");
                        }
                      } else if (cartModel!.product!.isSubscriptionProduct == 0 &&
                          cart.cartList
                              .where((element) =>
                          element.product!.isSubscriptionProduct == 1)
                              .isEmpty) {
                        if (productProvider.cartIndex == null && stock! > 0) {
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(cartModel);
                          showCustomSnackBar(
                              getTranslated('added_to_cart', context),
                              isError: false);
                        } else {
                          showCustomSnackBar(
                              getTranslated('already_added', context));
                        }
                      }
                      else {
                        showCustomSnackBar(
                            "either you can add subscription product or non-subscription product");
                      }
                    }
                  } : null,
                ))),


              ],
            ) : SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                    child: Column(children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Center(
                        child: SizedBox(
                          width: 1170,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                            Expanded(flex: 4, child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 350,
                                      child: Consumer<CartProvider>(
                                          builder: (context, cartProvider, child) {
                                            return CustomZoomWidget(
                                              image: ClipRRect(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                                                child: CustomImage(
                                                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                                                      productProvider.product!.image!.isNotEmpty ? productProvider.product!.image![cartProvider.productSelect] : ''}',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          }
                                      ),
                                    ),

                                    Positioned(
                                      top: 10, right: 10,
                                      child: WishButton(product: productProvider.product, edgeInset: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                SizedBox(height: 70, child: productProvider.product!.image != null ? SelectedImageWidget(productModel: productProvider.product) : const SizedBox(),),
                              ],
                            )),

                            const SizedBox(width: 30),
                            Expanded(flex: 6,child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  ProductTitleView(product: productProvider.product, stock: stock, cartIndex: productProvider.cartIndex),

                                  VariationView(product: productProvider.product),

                                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    CustomDirectionality(child: Text(
                                      PriceConverter.convertPrice(context, priceWithQuantity),
                                      style: poppinsBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeMaxLarge,
                                      ),
                                    )),
                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),


                                  Row(
                                    children: [

                                      Builder(
                                          builder: (context) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).disabledColor.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                                              ),

                                              child: Row(children: [
                                                QuantityButton(
                                                  isIncrement: false, quantity: productProvider.quantity,
                                                  stock: stock, cartIndex: productProvider.cartIndex,
                                                  maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                                ),
                                                const SizedBox(width: 15),

                                                Consumer<CartProvider>(builder: (context, cart, child) {
                                                  return Text(productProvider.cartIndex != null ? cart.cartList[productProvider.cartIndex!].quantity.toString()
                                                      : productProvider.quantity.toString(), style: poppinsBold.copyWith(color: Theme.of(context).primaryColor)
                                                  );
                                                }),
                                                const SizedBox(width: 15),

                                                QuantityButton(
                                                  isIncrement: true, quantity: productProvider.quantity,
                                                  stock: stock, cartIndex: productProvider.cartIndex,
                                                  maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                                ),
                                              ]),
                                            );
                                          }
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeDefault),

                                      Builder(
                                        builder: (context) => Center(
                                          child: SizedBox(
                                            width: 200,
                                            child: CustomButton(
                                              icon: Icons.shopping_cart,
                                              buttonText: getTranslated(productProvider.cartIndex != null ? 'already_added' : stock! <= 0 ? 'out_of_stock' : 'add_to_card', context),
                                              onPressed: (productProvider.cartIndex == null && stock! > 0) ? () {
                                                if(cart.cartList.isEmpty){
                                                  if (productProvider.cartIndex == null && stock! > 0) {
                                                    Provider.of<CartProvider>(context, listen: false)
                                                        .addToCart(cartModel!);
                                                    showCustomSnackBar(
                                                        getTranslated('added_to_cart', context),
                                                        isError: false);
                                                  } else {
                                                    showCustomSnackBar(
                                                        getTranslated('already_added', context));
                                                  }
                                                }else {
                                                  if (cart.cartList
                                                      .where((element) =>
                                                  element.product!.isSubscriptionProduct == 0)
                                                      .isEmpty &&
                                                      cartModel!.product!.isSubscriptionProduct == 1) {

                                                    if(cart.cartList.where((element) => element.id == cartModel!.product!.id).isNotEmpty) {
                                                      if (productProvider.cartIndex == null && stock! > 0) {
                                                        Provider.of<CartProvider>(context, listen: false)
                                                            .addToCart(cartModel);
                                                        showCustomSnackBar(
                                                            getTranslated('added_to_cart', context),
                                                            isError: false);
                                                      } else {
                                                        showCustomSnackBar(
                                                            getTranslated('already_added', context));
                                                      }
                                                    }else{
                                                      showCustomSnackBar("you can not choose more then one subscription product at a time.");
                                                    }
                                                  } else if (cartModel!.product!.isSubscriptionProduct == 0 &&
                                                      cart.cartList
                                                          .where((element) =>
                                                      element.product!.isSubscriptionProduct == 1)
                                                          .isEmpty) {
                                                    if (productProvider.cartIndex == null && stock! > 0) {
                                                      Provider.of<CartProvider>(context, listen: false)
                                                          .addToCart(cartModel);
                                                      showCustomSnackBar(
                                                          getTranslated('added_to_cart', context),
                                                          isError: false);
                                                    } else {
                                                      showCustomSnackBar(
                                                          getTranslated('already_added', context));
                                                    }
                                                  }
                                                  else {
                                                    showCustomSnackBar(
                                                        "either you can add subscription product or non-subscription product");
                                                  }
                                                }
                                              } : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ))
                          ],),
                        ),
                      ),
                      //Description

                      const SizedBox(height : 30),
                      Center(child: SizedBox(width: Dimensions.webScreenWidth, child: _description(context, productProvider))),
                      const SizedBox(height: Dimensions.paddingSizeDefault,),
                    ]),
                  ),

                  const FooterView(),
                ],
              ),
            ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
          },
        );
      }),
    );
  }

  Widget _description(BuildContext context, ProductProvider productProvider) {
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
      Consumer<ProductProvider>(
        builder: (context, productProvider, child) {

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: (){
                      setState(() {
                        _tabIndex = 0;
                      });
                    },
                    child: Column(
                      children: [

                        Text(getTranslated('description', context), style: poppinsSemiBold.copyWith(
                          color: _tabIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        )),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Container(
                          height: 3,
                          color: _tabIndex == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.05),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: ResponsiveHelper.isDesktop(context) ? 1 : 3,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: (){
                      setState(() {
                        _tabIndex = 1;
                      });
                    },
                    child: Column(

                      children: [

                        Text(getTranslated('review', context), style: poppinsSemiBold.copyWith(
                          color: _tabIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        )),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Container(
                          height: 3,
                          color: _tabIndex == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.05),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      const Text('', style: poppinsSemiBold),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Container(
                        height: 3,
                        color: Theme.of(context).disabledColor.withOpacity(0.05),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),


      _tabIndex == 0 ? Stack(
        children: [
          Container(
            height: (productProvider.product != null && productProvider.product!.description != null && productProvider.product!.description!.length > 300) && showSeeMoreButton ? 100 : null,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            width: Dimensions.webScreenWidth,
            child: HtmlWidget(
              productProvider.product!.description ?? '',
              textStyle: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),

          if(productProvider.product!.description != null && productProvider.product!.description!.length > (ResponsiveHelper.isDesktop(context) ? 700 : 300) && showSeeMoreButton) Positioned.fill(child: Align(
            alignment: Alignment.bottomCenter, child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
              Theme.of(context).cardColor.withOpacity(0),
              Theme.of(context).cardColor,
            ])),
            width: Dimensions.webScreenWidth, height: 55,
          ),
          )),

          if(productProvider.product!.description != null && productProvider.product!.description!.length > (ResponsiveHelper.isDesktop(context) ? 700 : 300) && showSeeMoreButton) Positioned.fill(child: Align(
            alignment: Alignment.bottomCenter, child: InkWell(
            onTap: (){
              setState(() {
                showSeeMoreButton = false;
              });
            },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 7, offset: const Offset(0, 1))],
                ),
                height: 38, width: 100, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
              child: Text(getTranslated('see_more', context)),
                        )),
            ),
          )),


        ],
      ) : Column(children: [
        SizedBox(
          width: 700,
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${productProvider.product!.rating!.isNotEmpty
                    ? double.parse(productProvider.product!.rating!.first.average!).toStringAsFixed(1) : 0.0}',
                    style: poppinsRegular.copyWith(
                      fontSize: ResponsiveHelper.isDesktop(context) ? 60 : 30,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    )),
                //const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                RatingBar(
                  rating: productProvider.product!.rating!.isNotEmpty
                      ? double.parse(productProvider.product!.rating![0].average!)
                      : 0.0, size: 25,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  '${productProvider.product!.activeReviews!.length} ${getTranslated('review', context)}',
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),


              ],),

            const SizedBox(height: Dimensions.paddingSizeSmall,),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: RatingLine(),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

          ]),
        ),

        ListView.builder(
          itemCount: productProvider.product!.activeReviews!.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
          itemBuilder: (context, index) {
            return productProvider.product!.activeReviews != null
                ? ReviewWidget(reviewModel: productProvider.product!.activeReviews![index])
                : const ReviewShimmer();
          },
        ),
      ]) ,
    ],);
  }
}

class SelectedImageWidget extends StatelessWidget {
  final Product? productModel;
  const SelectedImageWidget({Key? key, this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return ListView.builder(
          itemCount: productProvider.product!.image!.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          itemBuilder: (context,index){
            return Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: (){
                  Provider.of<CartProvider>(context, listen: false).setSelect(index, true);
                },
                child: Container(
                  padding: EdgeInsets.all(Provider.of<CartProvider>(context, listen: false).productSelect == index ? 3 : 0),
                  width: ResponsiveHelper.isDesktop(context) ? 70 : 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                    border: Border.all(color: Provider.of<CartProvider>(context, listen: false).productSelect == index ? Theme.of(context).primaryColor : ColorResources.getGreyColor(context),width: 1)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                    child: CustomImage(
                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${productProvider.product!.image![index]}',
                      width: ResponsiveHelper.isDesktop(context) ? 70 : 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          });
      }
    );
  }
}

