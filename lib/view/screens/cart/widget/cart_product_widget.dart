import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int index;
  const CartProductWidget({Key? key, required this.cart, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String? variationText = '';
    if(cart.variation !=null ) {
      List<String> variationTypes = cart.variation!.type!.split('-');
      if(variationTypes.length == cart.product!.choiceOptions!.length) {
        int index = 0;
        for (var choice in cart.product!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      }else {
        variationText = cart.product!.variations![0].type;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteHelper.getProductDetailsRoute(productId: cart.product?.id),
          );
        },
        child: Stack(children: [
          const Positioned(
            top: 0, bottom: 0, right: 0, left: 0,
            child: Icon(Icons.delete, color: Colors.white, size: 50),
          ),
          Dismissible(
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) {
              Provider.of<ProductProvider>(context, listen: false).setExistData(null);
              Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
              Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 200]!,
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(crossAxisAlignment : ResponsiveHelper.isDesktop(context) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisAlignment: ResponsiveHelper.isDesktop(context) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                  children: [

                Container(
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)), borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImage(
                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${cart.image}',
                      height: ResponsiveHelper.isDesktop(context) ? 100 : 70, width: ResponsiveHelper.isDesktop(context) ? 100 : 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                !ResponsiveHelper.isDesktop(context) ? Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(cart.name!, style: poppinsRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                      ), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('${cart.capacity} ${cart.unit}', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(children: [

                        CustomDirectionality(child: Text(
                          PriceConverter.convertPrice(context, cart.discountedPrice),
                          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                        )),
                        SizedBox(width: cart.discountedPrice!=null ? Dimensions.paddingSizeExtraSmall : 0),

                        CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(context, cart.price),
                        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                      )),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      if(cart.product != null && cart.product!.variations != null && cart.product!.variations!.isNotEmpty)  Row(children: [
                        Text('${getTranslated('variation', context)}: ', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                        Flexible(child: Text(variationText!, style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ))),
                      ]),
                    ]),
                ) : Expanded(
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Column(children: [
                      SizedBox(
                          width: 150,
                          child: Text(cart.name!, style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      if(cart.product != null && cart.product!.variations != null && cart.product!.variations!.isNotEmpty )  SizedBox(
                        width: 150,
                        child: Wrap(children: [
                          Text('${getTranslated('variation', context)}: ', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                          Text(variationText!, style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          )),
                        ]),
                      ),

                    ]),

                    Text('${cart.capacity} ${cart.unit}', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),

                    Row(children: [

                      CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(context, cart.discountedPrice),
                        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                      )),
                      SizedBox(width: cart.discountedPrice!=null ? Dimensions.paddingSizeExtraSmall : 0),

                      CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(context, cart.price),
                        style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                      )),

                    ]),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                  ]),
                ),


                RotatedBox(
                  quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),

                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [

                      InkWell(
                        onTap: () {
                          if(cart.product!.maximumOrderQuantity == null || cart.quantity! < cart.product!.maximumOrderQuantity!) {
                            if(cart.quantity! < cart.stock!) {
                              Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                              Provider.of<CartProvider>(context, listen: false).setQuantity(true, index, showMessage: true, context: context);
                            }else {
                              showCustomSnackBar(getTranslated('out_of_stock', context));
                            }
                          }else{
                            showCustomSnackBar('${getTranslated('you_can_add_max', context)} ${cart.product!.maximumOrderQuantity} ${
                                getTranslated(cart.product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault :  Dimensions.paddingSizeSmall),
                          child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                        ),
                      ),

                      RotatedBox(quarterTurns: ResponsiveHelper.isMobile() ? 0 : 3, child: Text(cart.quantity.toString(), style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,color: Theme.of(context).primaryColor))),

                      RotatedBox(
                        quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                        child: (ResponsiveHelper.isDesktop(context) && cart.quantity == 1) ? Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                          child: IconButton(
                            onPressed: () {
                              Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
                              Provider.of<ProductProvider>(context, listen: false).setExistData(null);
                            },
                            icon: const RotatedBox(quarterTurns: 2, child: Icon(CupertinoIcons.delete, color: Colors.red, size: 20)),
                          ),
                        ) : InkWell(
                          onTap: () {
                            Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                            if (cart.quantity! > 1) {
                              Provider.of<CartProvider>(context, listen: false).setQuantity(false, index,showMessage: true, context: context);
                            }else if(cart.quantity == 1){
                              Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
                              Provider.of<ProductProvider>(context, listen: false).setExistData(null);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            child: Icon(Icons.remove, size: 20,color: Theme.of(context).disabledColor),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

                /*!ResponsiveHelper.isMobile() ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: IconButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
                      Provider.of<ProductProvider>(context, listen: false).setExistData(null);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ) : const SizedBox(),*/

              ]),
            ),
          ),
        ]),
      ),
    );
  }
}


class CartProductListView extends StatelessWidget {
  const CartProductListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartProvider.cartList.length,
            itemBuilder: (context, index) {
              return CartProductWidget(cart: cartProvider.cartList[index], index: index,);
            },
          );
        }
    );
  }
}
