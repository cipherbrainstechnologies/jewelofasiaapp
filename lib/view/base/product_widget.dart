import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:provider/provider.dart';

import 'wish_button.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final String productType;
  final bool isGrid;
  final bool isCenter;
  ProductWidget({Key? key, required this.product, this.productType = ProductType.dailyItem, this.isGrid = false, this.isCenter = false}) : super(key: key);


  final oneSideShadow = Padding(
    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
    child: Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {

    double? priceWithDiscount = 0;
    double? categoryDiscountAmount;
    if(product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverter.convertWithDiscount(
        product.price, product.categoryDiscount!.discountAmount, product.categoryDiscount!.discountType,
        maxDiscount: product.categoryDiscount!.maximumAmount,
      );
    }

    priceWithDiscount = PriceConverter.convertWithDiscount(product.price, product.discount, product.discountType);


    if(categoryDiscountAmount != null && categoryDiscountAmount > 0
        && categoryDiscountAmount  < priceWithDiscount!) {
      priceWithDiscount = categoryDiscountAmount;

    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        double? price = 0;
        int? stock = 0;
        bool isExistInCart = false;
        int? cardIndex;
        CartModel? cartModel;
        if(product.variations!.isNotEmpty) {
          for(int index=0; index<product.variations!.length; index++) {
            price = product.variations!.isNotEmpty ? product.variations![index].price : product.price;
            stock = product.variations!.isNotEmpty ? product.variations![index].stock : product.totalStock;
            cartModel = CartModel(product.id, product.image!.isNotEmpty ? product.image![0] : '', product.name, price,
                PriceConverter.convertWithDiscount(price, product.discount, product.discountType),
                1,
                product.variations!.isNotEmpty ? product.variations![index] : null,
                (price! - PriceConverter.convertWithDiscount(price, product.discount, product.discountType)!),
                (price - PriceConverter.convertWithDiscount(price, product.tax, product.taxType)!),
                product.capacity,
                product.unit,
                stock,product
            );
            isExistInCart = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel) != null;
            cardIndex = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel);
            if(isExistInCart) {
              break;
            }
          }
        }else {
          price = product.variations!.isNotEmpty ? product.variations![0].price! : product.price!;
          stock = product.variations!.isNotEmpty ? product.variations![0].stock! : product.totalStock!;
          cartModel = CartModel(product.id, product.image!.isNotEmpty ?  product.image![0] : '', product.name, price,
              PriceConverter.convertWithDiscount(price, product.discount, product.discountType),
              1,
              product.variations!.isNotEmpty ? product.variations![0] : null,
              (price - PriceConverter.convertWithDiscount(price, product.discount, product.discountType)!),
              (price - PriceConverter.convertWithDiscount(price, product.tax, product.taxType)!),
              product.capacity,
              product.unit,
              stock,product
          );
          isExistInCart = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel) != null;
          cardIndex = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel);
        }

        return isGrid ? OnHover(isItem: true, child: _productGridView(context, isExistInCart, stock, cartModel, cardIndex, priceWithDiscount!)) : Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: InkWell(
            hoverColor: Colors.transparent,
            onTap: () => Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
              productId: product.id, formSearch: productType == ProductType.searchItem,
            )),

            child: OnHover(
              isItem: true,
              child: Container(
                height: 110,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 4), blurRadius: 7, spreadRadius: 0.1)],
                ),
                child: Row(children: [

                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImage(
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                                product.image!.isNotEmpty ? product.image![0] : ''}',
                            height: 110, width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      product.discount != 0 ? Positioned(
                        top: 5, left: 5,
                        child: DiscountTag(product: product),
                      ) : const SizedBox(),

                      Positioned(
                        top: ResponsiveHelper.isDesktop(context) ? null : 5,
                        right: ResponsiveHelper.isDesktop(context) ? 5 : 5,
                        bottom: ResponsiveHelper.isDesktop(context) ? 5 : null,
                        child: !isExistInCart
                            ? InkWell(
                            onTap: () {
                              if(product.variations == null || product.variations!.isEmpty) {
                                if (isExistInCart) {
                                  showCustomSnackBar('already_added'.tr);
                                } else if (stock! < 1) {
                                  showCustomSnackBar('out_of_stock'.tr);
                                } else {
                                  Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!);
                                  showCustomSnackBar('added_to_cart'.tr, isError: false);
                                }
                              }else {
                                Navigator.of(context).pushNamed(
                                  RouteHelper.getProductDetailsRoute(
                                    productId: product.id, formSearch:productType == ProductType.searchItem,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.all(2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Icon(Icons.shopping_cart_outlined,
                                  color: Theme.of(context).primaryColor),
                            )) : Consumer<CartProvider>(builder: (context, cart, child) => RotatedBox(
                          quarterTurns: ResponsiveHelper.isDesktop(context) ? 0 : 3,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Theme.of(context).primaryColor.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).cardColor,
                            ),

                            child: Row(children: [
                              InkWell(
                                onTap: () {
                                  if (cart.cartList[cardIndex!].quantity! > 1) {
                                    Provider.of<CartProvider>(context, listen: false).setQuantity(false, cardIndex, context: context, showMessage: true);
                                  } else {
                                    Provider.of<CartProvider>(context, listen: false).removeFromCart(cardIndex, context);
                                  }
                                },
                                child: RotatedBox(
                                  quarterTurns: ResponsiveHelper.isDesktop(context) ? 0 : 1,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall,
                                        vertical: Dimensions.paddingSizeExtraSmall),
                                    child: Icon(Icons.remove, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                                  ),
                                ),
                              ),

                              RotatedBox(
                                quarterTurns: ResponsiveHelper.isDesktop(context) ? 0 : 1,
                                child: Text(
                                    cart.cartList[cardIndex!].quantity.toString(),
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                        color: Theme.of(context).textTheme.bodyLarge!.color)),
                              ),


                              InkWell(
                                onTap: () {
                                  if(cart.cartList[cardIndex!].product!.maximumOrderQuantity == null || cart.cartList[cardIndex].quantity! < cart.cartList[cardIndex].product!.maximumOrderQuantity!) {
                                    if(cart.cartList[cardIndex].quantity! < cart.cartList[cardIndex].stock!) {
                                      cart.setQuantity(true, cardIndex, showMessage: true, context: context);
                                    }else {
                                      showCustomSnackBar(getTranslated('out_of_stock', context));
                                    }
                                  }else{
                                    showCustomSnackBar('${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Icon(Icons.add, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        ),
                      )
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            product.rating != null ? Row(mainAxisAlignment: isCenter ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                              const Icon(Icons.star_rounded, color: ColorResources.ratingColor, size: 20),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(product.rating!.isNotEmpty ? double.parse(product.rating![0].average!).toStringAsFixed(1) : '0.0', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                            ]) : const SizedBox(),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(product.name!,
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            Text('${product.capacity} ${product.unit}', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

                            Flexible(
                              child: Row(children: [
                                product.price! > priceWithDiscount! ? CustomDirectionality(child: Text(
                                  PriceConverter.convertPrice(context, product.price),
                                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough, color: Theme.of(context).disabledColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )) : const SizedBox(),

                                product.price! > priceWithDiscount ? const SizedBox(width: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                                CustomDirectionality(child: Text(
                                  PriceConverter.convertPrice(context, priceWithDiscount),
                                  style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )),

                              ],),
                            ),
                          ]),
                    ),
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: WishButton(product: product, edgeInset: const EdgeInsets.all(5)),
                  ),

                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  InkWell _productGridView(BuildContext context, bool isExistInCart, int? stock, CartModel? cartModel, int? cardIndex, double priceWithDiscount) {

    return InkWell(
      hoverColor: Colors.transparent,
      borderRadius:  BorderRadius.circular(Dimensions.radiusSizeTen),
      onTap: () {
        Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
          productId: product.id, formSearch:productType == ProductType.searchItem,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 7,
              spreadRadius: 0.1,
            ),]),
        child: Stack(children: [
          Column(children: [
            Expanded(
              flex: 7,
              child: Stack(children: [
                oneSideShadow,

                Container(
                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Dimensions.radiusSizeTen),
                    ),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Dimensions.radiusSizeTen),
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: Images.getPlaceHolderImage(context),
                      height: 190,
                      fit: BoxFit.cover,
                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                          product.image!.isNotEmpty ? product.image![0] : ''}',
                      imageErrorBuilder: (c, o, s) => Image.asset(Images.getPlaceHolderImage(context), width: 80, height: 190, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
              ),),

            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: isCenter ? CrossAxisAlignment.center: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    product.rating != null ? Row(mainAxisAlignment: isCenter ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                      const Icon(Icons.star_rounded, color: ColorResources.ratingColor, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(product.rating!.isNotEmpty ? double.parse(product.rating![0].average!).toStringAsFixed(1) : '0.0', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                    ]) : const SizedBox(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        product.name!,
                        style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isCenter ? TextAlign.center : TextAlign.start,
                      ),
                    ),

                    isCenter ? const SizedBox() : Divider(height: 15, thickness: 1, color: ColorResources.getGreyColor(context).withOpacity(0.5)),

                    isCenter ? Text(
                      '${product.capacity} ${product.unit}',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ) : const SizedBox(),

                    isCenter ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        product.price! > priceWithDiscount  ?
                        CustomDirectionality(
                          child: Text(
                            PriceConverter.convertPrice(context, product.price),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ) : const SizedBox(),

                        CustomDirectionality(child: Text(
                          PriceConverter.convertPrice(context, priceWithDiscount),
                          style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        )),
                      ],
                    ) : Row(
                      children: [
                        Text(
                          '${product.capacity} ${product.unit}',
                          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),

                        product.price! > priceWithDiscount  ?
                        CustomDirectionality(
                          child: Text(
                            PriceConverter.convertPrice(context, product.price),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ) : const SizedBox(),

                        CustomDirectionality(child: Text(
                          PriceConverter.convertPrice(context, priceWithDiscount),
                          style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        )),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  ],
                ),
              ),
            ),
          ],),

          product.discount != 0 ? Positioned.fill(
            top: 17, left: 17,
            child: Align(
              alignment: Alignment.topLeft,
              child: DiscountTag(product: product),
            ),
          ) : const SizedBox(),

          Positioned.fill(
            top: 17, right: 17,
            child: Align(
              alignment: Alignment.topRight,
              child: WishButton(product: product, edgeInset: const EdgeInsets.all(5.0)),
            ),
          ),

          Positioned.fill(
            right: 17, top: 60,
            child: Align(
              alignment: Alignment.topRight,
              child: !isExistInCart ? InkWell(
                onTap: () {
                  if(product.variations == null || product.variations!.isEmpty) {
                    if (isExistInCart) {
                      showCustomSnackBar('already_added'.tr);
                    } else if (stock! < 1) {
                      showCustomSnackBar('out_of_stock'.tr);
                    } else {
                      Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!);
                      showCustomSnackBar('added_to_cart'.tr, isError: false);
                    }
                  }else {
                    Navigator.of(context).pushNamed(
                      RouteHelper.getProductDetailsRoute(
                        productId: product.id, formSearch:productType == ProductType.searchItem,
                      ),
                    );
                  }
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)),
                    ),
                    child: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).primaryColor, size: 25,)
                ),
              ) : Consumer<CartProvider>(builder: (context, cart, child) => RotatedBox(
                quarterTurns: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Theme.of(context).primaryColor.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),

                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    InkWell(
                      onTap: () {
                        if (cart.cartList[cardIndex!].quantity! > 1) {
                          Provider.of<CartProvider>(context, listen: false).setQuantity(false, cardIndex, context: context, showMessage: true);
                        } else {
                          Provider.of<CartProvider>(context, listen: false).removeFromCart(cardIndex, context);
                        }
                      },
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                              vertical: Dimensions.paddingSizeExtraSmall),
                          child: Icon(Icons.remove, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                    ),

                    RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        cart.cartList[cardIndex!].quantity.toString(),
                        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    ),


                    InkWell(
                      onTap: () {
                        if(cart.cartList[cardIndex].product!.maximumOrderQuantity == null || cart.cartList[cardIndex].quantity! < cart.cartList[cardIndex].product!.maximumOrderQuantity!) {
                          if(cart.cartList[cardIndex].quantity! < cart.cartList[cardIndex].stock!) {
                            cart.setQuantity(true, cardIndex, showMessage: true, context: context);
                          }else {
                            showCustomSnackBar(getTranslated('out_of_stock', context));
                          }
                        }else{
                          showCustomSnackBar('${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall),
                        child: Icon(Icons.add, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    ),
                  ]),
                ),
              ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class DiscountTag extends StatelessWidget {
  const DiscountTag({Key? key, required this.product,}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusSizeTen),
          bottomLeft: Radius.circular(Dimensions.radiusSizeTen),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              product.discountType == 'percent' ? '-${product.discount} %' : '-${PriceConverter.convertPrice(context, product.discount)}',
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
            ),
          ),
        ],
      ),
    );
  }
}


