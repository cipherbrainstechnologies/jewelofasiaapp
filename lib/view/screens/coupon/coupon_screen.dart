
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

import '../../base/footer_view.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    final bool isGuestCheckout = Provider.of<SplashProvider>(context, listen: false).configModel?.isGuestCheckout ?? false;
    if(isLoggedIn || isGuestCheckout) {
      Provider.of<CouponProvider>(context, listen: false).getCouponList(context);
    }

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()? null: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): const AppBarBase()) as PreferredSizeWidget?,
      body: isLoggedIn || isGuestCheckout ? Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return couponProvider.couponList != null ? couponProvider.couponList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await couponProvider.getCouponList(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                        child: Container(
                          padding: width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeLarge) : EdgeInsets.zero,
                          child: Container(
                            width: width > 700 ? 700 : width,
                            padding: width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
                            decoration: width > 700 ? BoxDecoration(
                              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 1)],
                            ) : null,
                            child: ListView.builder(
                              itemCount: couponProvider.couponList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: couponProvider.couponList![index].code ?? ''));
                                      showCustomSnackBar(getTranslated('coupon_code_copied', context), isError:  false);
                                    },
                                    child: Stack(children: [

                                      Image.asset(Images.couponBg, height: 100, width: 1170, fit: BoxFit.fitWidth, color: Theme.of(context).primaryColor),

                                      Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child: Row(children: [

                                          SizedBox(width: ResponsiveHelper.isDesktop(context) ? 60 : 40),
                                          Image.asset(Images.percentage, height: 40, width: 40),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                                            child: Image.asset(Images.line, height: 100, width: 5),
                                          ),

                                          Expanded(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                              SelectableText(
                                                couponProvider.couponList![index].code!,
                                                style: poppinsRegular.copyWith(color: Colors.white),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(
                                                couponProvider.couponList![index].couponType == 'free_delivery' ? getTranslated('free_delivery', context) :
                                                    '${couponProvider.couponList![index].discount}${couponProvider.couponList![index].discountType == 'percent' ? '%'
                                                    : Provider.of<SplashProvider>(context, listen: false).configModel!.currencySymbol} off',
                                                style: poppinsMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(
                                                '${getTranslated('valid_until', context)} ${DateConverter.isoStringToLocalDateOnly(couponProvider.couponList![index].expireDate!)}',
                                                style: poppinsRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                              ),
                                            ]),
                                          ),

                                        ]),
                                      ),

                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(ResponsiveHelper.isDesktop(context))  const FooterView()
                  ],
                ),
              ),
            ),
          ) : NoDataScreen(title: getTranslated('coupon_not_found', context)) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
        },
      ) : const NotLoggedInScreen(),
    );
  }
}
