// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:provider/provider.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int? status;

  const OrderSuccessfulScreen({Key? key, required this.orderID, this.status,}) : super(key: key);

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();

}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  // bool _isReload = true;
  @override
  void initState() {
    if(widget.status == 0) {
      Provider.of<OrderProvider>(context, listen: false).trackOrder(widget.orderID, null, context, false, isUpdate: false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: (() {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (_) => const MenuScreen(),
        ), (route) => false);
        return Future(() => true);
      }),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): null,
        body: Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
              double total = 0;
              bool success = true;



              if(orderProvider.trackModel != null && Provider.of<SplashProvider>(context, listen: false).configModel!.loyaltyPointItemPurchasePoint != null) {
                total = ((orderProvider.trackModel!.orderAmount! / 100
                ) * Provider.of<SplashProvider>(context, listen: false).configModel!.loyaltyPointItemPurchasePoint!);

              }

              return orderProvider.isLoading ? CustomLoader(color: Theme.of(context).primaryColor) :
              SingleChildScrollView(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
                      child: SizedBox(
                        width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width * 0.3 : 1170,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                         widget.status == 0 ? Image.asset(
                           Images.orderPlaced, width: 150, height: 150, color: Theme.of(context).primaryColor,
                         ) : const Icon(Icons.sms_failed_outlined, size: 150),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text(
                            getTranslated(widget.status == 0 ? 'order_placed_successfully' : widget.status == 1 ? 'payment_failed' : 'payment_cancelled', context),
                            style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                         if(widget.status == 0 && widget.orderID != 'null') Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${getTranslated('order_id', context)}:  #${widget.orderID}',
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                          ]),
                          const SizedBox(height: 30),

                          (success && Provider.of<AuthProvider>(context, listen: false).isLoggedIn() && Provider.of<SplashProvider>(context).configModel!.loyaltyPointStatus!  && total.floor() > 0 )  ? Column(children: [

                            Image.asset(
                              Provider.of<ThemeProvider>(context, listen: false).darkTheme
                                  ? Images.gifBoxDark : Images.gifBox,
                              width: 150, height: 150,
                            ),

                            Text(getTranslated('congratulations', context), style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                              child: Text(
                                '${getTranslated('you_have_earned', context)} ${total.floor().toString()} ${getTranslated('points_it_will_add_to', context)}',
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          ]) : const SizedBox.shrink() ,
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if(widget.status == 0) SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              child: CustomButton(
                                  buttonText: getTranslated('track_order', context),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, RouteHelper.getOrderTrackingRoute(
                                      int.parse(widget.orderID!),
                                      null,
                                    ));
                                  }),
                            ),
                          ),

                          SizedBox(width: MediaQuery.of(context).size.width, child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                            child: CustomButton(
                                buttonText: getTranslated('back_home', context),
                                onPressed: () {
                                  splashProvider.setPageIndex(0);
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                    builder: (_) => const MenuScreen(),
                                  ), (route) => false);
                                }),
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),



                        ]),
                      ),
                    ),
                  ),
                  ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
