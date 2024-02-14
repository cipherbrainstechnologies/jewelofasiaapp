import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/cart/widget/cart_product_widget.dart';
import 'package:flutter_grocery/view/screens/checkout/checkout_screen.dart';
import 'package:provider/provider.dart';

import 'widget/cart_details_view.dart';

class CartScreen extends StatefulWidget {

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    _couponController.clear();
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<OrderProvider>(context, listen: false).setOrderType('delivery', notify: false);


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    bool isSelfPickupActive = configModel.selfPickup == 1;
    bool kmWiseCharge = configModel.deliveryManagement!.status!;

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone() ? null: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : const AppBarBase()) as PreferredSizeWidget?,
      body: Center(
        child: Consumer<CouponProvider>(builder: (context, couponProvider, _) {
            return Consumer<CartProvider>(
              builder: (context, cart, child) {
                double? deliveryCharge = 0;
                (Provider.of<OrderProvider>(context).orderType == 'delivery' && !kmWiseCharge)
                    ? deliveryCharge = configModel.deliveryCharge : deliveryCharge = 0;

                if(couponProvider.couponType == 'free_delivery') {
                  deliveryCharge = 0;
                }

                double itemPrice = 0;
                double discount = 0;
                double tax = 0;
                for (var cartModel in cart.cartList) {
                  itemPrice = itemPrice + (cartModel.price! * cartModel.quantity!);
                  discount = discount + (cartModel.discount! * cartModel.quantity!);
                  tax = tax + (cartModel.tax! * cartModel.quantity!);
                }

                double subTotal = itemPrice + (configModel.isVatTexInclude! ? 0 : tax);
                bool isFreeDelivery = subTotal >= configModel.freeDeliveryOverAmount! && configModel.freeDeliveryStatus!
                    || couponProvider.couponType == 'free_delivery';

                double total = subTotal - discount - Provider.of<CouponProvider>(context).discount! + (isFreeDelivery ? 0 : deliveryCharge!);

                return cart.cartList.isNotEmpty
                    ? !ResponsiveHelper.isDesktop(context) ? Column(children: [
                      Expanded(child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Product
                            const CartProductListView(),
                            //const SizedBox(height: Dimensions.paddingSizeDefault),

                            CartDetailsView(
                            couponController: _couponController, total: total,
                            isSelfPickupActive: isSelfPickupActive,
                            kmWiseCharge: kmWiseCharge, isFreeDelivery: isFreeDelivery,
                            itemPrice: itemPrice, tax: tax,
                            discount: discount, deliveryCharge: deliveryCharge!,
                          ),
                            const SizedBox(height: 40),
                          ]),
                        )),
                      )),

                      CartButtonView(
                        subTotal: subTotal,
                        configModel: configModel,
                        itemPrice: itemPrice,
                        total: total,
                        isFreeDelivery: isFreeDelivery,
                        deliveryCharge: deliveryCharge,
                      ),
                    ])
                    : SingleChildScrollView(child: Column(children: [
                      Center(child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: ResponsiveHelper.isDesktop(context)
                              ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height,
                        ),
                        child: SizedBox(width: 1170, child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: Container(
                                padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeLarge,
                                  right: Dimensions.paddingSizeLarge,
                                  top: Dimensions.paddingSizeLarge,
                                  bottom: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.01), spreadRadius: 1, blurRadius: 1),
                                  ],
                                ),
                                child: const CartProductListView(),
                              ),
                              ),
                              const SizedBox(width: 20),

                              Expanded(flex:4, child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                                CartDetailsView(
                                  couponController: _couponController, total: total,
                                  isSelfPickupActive: isSelfPickupActive,
                                  kmWiseCharge: kmWiseCharge, isFreeDelivery: isFreeDelivery,
                                  itemPrice: itemPrice, tax: tax,
                                  discount: discount, deliveryCharge: deliveryCharge!,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                CartButtonView(
                                  subTotal: subTotal,
                                  configModel: configModel,
                                  itemPrice: itemPrice,
                                  total: total,
                                  isFreeDelivery: isFreeDelivery,
                                  deliveryCharge: deliveryCharge,
                                ),
                              ]))

                            ],
                          ),
                        )),
                      )),

                      const FooterView(),
                ]))
                    :  NoDataScreen(image: Images.favouriteNoDataImage, title: getTranslated('empty_shopping_bag', context));
              },
            );
          }
        ),
      ),
    );
  }
}

class CartButtonView extends StatelessWidget {
  const CartButtonView({
    Key? key,
    required double subTotal,
    required ConfigModel configModel,
    required double itemPrice,
    required double total,
    required double deliveryCharge,
    required bool isFreeDelivery,
  }) : _subTotal = subTotal, _configModel = configModel,
        _isFreeDelivery = isFreeDelivery, _itemPrice = itemPrice,
        _total = total, _deliveryCharge = deliveryCharge, super(key: key);

  final double _subTotal;
  final ConfigModel _configModel;
  final double _itemPrice;
  final double _total;
  final bool _isFreeDelivery;
  final double _deliveryCharge;

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(child: Container(
      width: 1170,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(children: [

        Consumer<CouponProvider>(
          builder: (context, couponProvider, _) {
            return couponProvider.couponType == 'free_delivery'
                ? const SizedBox() :
            FreeDeliveryProgressBar(subTotal: _subTotal, configModel: _configModel);
          }
        ),

        CustomButton(
          buttonText: getTranslated('proceed_to_checkout', context),
          onPressed: () {
            if(_itemPrice < _configModel.minimumOrderValue!) {
              showCustomSnackBar(' ${getTranslated('minimum_order_amount_is', context)} ${PriceConverter.convertPrice(context, _configModel.minimumOrderValue)
              }, ${getTranslated('you_have', context)} ${PriceConverter.convertPrice(context, _itemPrice)} ${getTranslated('in_your_cart_please_add_more_item', context)}', isError: true);
            } else {
              String? orderType = Provider.of<OrderProvider>(context, listen: false).orderType;
              double? discount = Provider.of<CouponProvider>(context, listen: false).discount;
              Navigator.pushNamed(
                context, RouteHelper.getCheckoutRoute(
                _total, discount, orderType,
                Provider.of<CouponProvider>(context, listen: false).code!,
                  _isFreeDelivery ? 'free_delivery' : '' , _deliveryCharge,
              ),
                arguments: CheckoutScreen(
                  amount: _total, orderType: orderType, discount: discount,
                  couponCode: Provider.of<CouponProvider>(context, listen: false).code,
                  freeDeliveryType:  _isFreeDelivery ? 'free_delivery' : '',
                  deliveryCharge: _deliveryCharge,
                ),
              );
            }
          },
        ),
      ]),
    ));
  }
}



class FreeDeliveryProgressBar extends StatelessWidget {
  const FreeDeliveryProgressBar({
    Key? key,
    required double subTotal,
    required ConfigModel configModel,
  }) : _subTotal = subTotal, super(key: key);

  final double _subTotal;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return configModel.freeDeliveryStatus! ? Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Row(children: [
            Icon(Icons.discount_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            (_subTotal / configModel.freeDeliveryOverAmount!)  < 1 ?
            CustomDirectionality(child: Text(
              '${PriceConverter.convertPrice(context, configModel.freeDeliveryOverAmount! - _subTotal)} ${getTranslated('more_to_free_delivery', context)}',
            ))
            : Text(getTranslated('enjoy_free_delivery', context)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          LinearProgressIndicator(
            value: (_subTotal / configModel.freeDeliveryOverAmount!),
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),
      ) : const SizedBox();
  }
}


