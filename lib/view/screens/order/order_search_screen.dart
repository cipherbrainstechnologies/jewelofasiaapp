import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/phone_number_field_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/order/widget/track_order_web_view.dart';
import 'package:provider/provider.dart';

class OrderSearchScreen extends StatefulWidget {
  const OrderSearchScreen({Key? key}) : super(key: key);

  @override
  State<OrderSearchScreen> createState() => _OrderSearchScreenState();
}

class _OrderSearchScreenState extends State<OrderSearchScreen> {
  final TextEditingController orderIdTextController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final FocusNode orderIdFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  String? countryCode;

  @override
  void initState() {
    countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.country!).code;

    Provider.of<OrderProvider>(context, listen: false).clearPrevData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(
        preferredSize: Size.fromHeight(100), child: WebAppBar(),
      ) : CustomAppBar(
        isBackButtonExist: !ResponsiveHelper.isMobile(),
        title: getTranslated('order_details', context),
        actionView: TrackRefreshButtonView(
          orderIdTextController: orderIdTextController,
          phoneNumberTextController: phoneNumberTextController,
        ),
      ) as PreferredSizeWidget,

      body: CustomScrollView(slivers: [

        SliverToBoxAdapter(child: Container(
          margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(horizontal: (MediaQuery.sizeOf(context).width - Dimensions.webScreenWidth) / 2).copyWith(top: Dimensions.paddingSizeDefault) : null,
          decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
            color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(children: [
            if(ResponsiveHelper.isDesktop(context)) Center(child: Container(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              width: Dimensions.webScreenWidth,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                const SizedBox(),
                Text(getTranslated('track_your_order', context), style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),

                TrackRefreshButtonView(
                  orderIdTextController: orderIdTextController,
                  phoneNumberTextController: phoneNumberTextController,
                ),


              ]),
            )),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(children: [

                Padding(
                  padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall,
                  ) : const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: InputView(
                    key: UniqueKey(),
                    orderIdTextController: orderIdTextController, orderIdFocusNode: orderIdFocusNode,
                    phoneFocusNode: phoneFocusNode, phoneNumberTextController: phoneNumberTextController,
                    onValueChange: (String code) {
                      setState(() {
                        countryCode = code;
                      });
                    },
                    countryCode: countryCode,

                  ),
                ),

               Consumer<OrderProvider>(builder: (context, orderProvider, _) {
                    return orderProvider.trackModel == null || orderProvider.trackModel?.id == null  ? Column(children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Image.asset(Images.outForDelivery, color: Theme.of(context).disabledColor.withOpacity(0.5), width:  70),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text(getTranslated('enter_your_order_id', context), style: poppinsRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                      ), maxLines: 2,  textAlign: TextAlign.center),
                      const SizedBox(height: 100),
                    ]) : ResponsiveHelper.isDesktop(context) ? TrackOrderWebView(
                      phoneNumber: '${CountryCode.fromCountryCode(countryCode!).dialCode}${phoneNumberTextController.text.trim()}',
                    ) : const SizedBox();
                }),


              ]),
            ),

          ]),
        )),

        if(ResponsiveHelper.isDesktop(context))  const SliverFillRemaining(
          hasScrollBody: false,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            SizedBox(height: Dimensions.paddingSizeLarge),

            FooterView(),
          ]),
        ),
      ]),
    );
  }
}


class TrackRefreshButtonView extends StatelessWidget {
  const TrackRefreshButtonView({
    Key? key,
    required this.orderIdTextController,
    required this.phoneNumberTextController,
  }) : super(key: key);

  final TextEditingController orderIdTextController;
  final TextEditingController phoneNumberTextController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 0,
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Theme.of(context).canvasColor : Theme.of(context).cardColor,
      onPressed: () {
        orderIdTextController.clear();
        phoneNumberTextController.clear();
        Provider.of<OrderProvider>(context, listen: false).clearPrevData(isUpdate: true);
      },
      label: Text(getTranslated('refresh', context), style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
      icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
    );
  }
}


class InputView extends StatelessWidget {
  const InputView({
    Key? key,
    required this.orderIdTextController,
    required this.orderIdFocusNode,
    required this.phoneFocusNode,
    required this.phoneNumberTextController,
    required this.countryCode,
    required this.onValueChange,
  }) : super(key: key);

  final TextEditingController orderIdTextController;
  final FocusNode orderIdFocusNode;
  final FocusNode phoneFocusNode;
  final TextEditingController phoneNumberTextController;
  final String? countryCode;
  final Function(String value) onValueChange;

  @override
  Widget build(BuildContext context) {

    return !ResponsiveHelper.isDesktop(context) ? Column(children: [
      FormField(builder: (builder)=> Column(children: [
        OrderIdTextField(
          orderIdTextController: orderIdTextController,
          orderIdFocusNode: orderIdFocusNode,
          phoneFocusNode: phoneFocusNode,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        PhoneNumberFieldView(
          onValueChange: onValueChange,
          countryCode: countryCode,
          phoneNumberTextController: phoneNumberTextController,
          phoneFocusNode: phoneFocusNode,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

      ])),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      TrackOrderButtonView(
        key: UniqueKey(),
        orderIdTextController: orderIdTextController,
        countryCode: countryCode,
        phoneNumberTextController: phoneNumberTextController,
      ),
    ]) : Center(child: SizedBox(
      width: Dimensions.webScreenWidth,
      child: FormField(builder: (builder)=> Row(children: [
        Expanded(child: OrderIdTextField(
          orderIdTextController: orderIdTextController,
          orderIdFocusNode: orderIdFocusNode,
          phoneFocusNode: phoneFocusNode,
        )),
        const SizedBox(width: Dimensions.paddingSizeLarge),

        Expanded(child: PhoneNumberFieldView(
          onValueChange: onValueChange, countryCode: countryCode,
          phoneNumberTextController: phoneNumberTextController,
          phoneFocusNode: phoneFocusNode,
        )),
        const SizedBox(width: Dimensions.paddingSizeLarge),


        SizedBox(
          width: 200,
          child: TrackOrderButtonView(
            key: UniqueKey(),
            orderIdTextController: orderIdTextController,
            countryCode: countryCode,
            phoneNumberTextController: phoneNumberTextController,
          ),
        ),
      ])),
    ));
  }
}

class TrackOrderButtonView extends StatelessWidget {
  const TrackOrderButtonView({
    Key? key,
    required this.orderIdTextController,
    required this.countryCode,
    required this.phoneNumberTextController,
  }) : super(key: key);

  final TextEditingController orderIdTextController;
  final String? countryCode;
  final TextEditingController phoneNumberTextController;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return orderProvider.isLoading ? CustomLoader(color: Theme.of(context).primaryColor) : CustomButton(
          borderRadius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSizeDefault : Dimensions.radiusSizeLarge,
          buttonText: getTranslated('search_order', context),
          onPressed: (){
            final String orderId = orderIdTextController.text.trim();
            final dialCode = CountryCode.fromCountryCode(countryCode!).dialCode;

            final String phoneNumber = '$dialCode${phoneNumberTextController.text.trim()}';

            if(orderId.isEmpty){
              showCustomSnackBar(getTranslated('enter_order_id', context));
            }else if(phoneNumberTextController.text.trim().isEmpty){
              showCustomSnackBar(getTranslated('enter_phone_number', context));
            }else{
              if(ResponsiveHelper.isDesktop(context)){
                orderProvider.trackOrder(orderId, null, context, true, phoneNumber: phoneNumber);
              }else{
                Navigator.of(context).pushNamed(
                  RouteHelper.getOrderTrackingRoute(int.parse(orderId),  phoneNumber),
                );
              }
            }

          },
        );
      }
    );
  }
}



class OrderIdTextField extends StatelessWidget {
  const OrderIdTextField({
    Key? key,
    required this.orderIdTextController,
    required this.orderIdFocusNode,
    required this.phoneFocusNode,
  }) : super(key: key);

  final TextEditingController orderIdTextController;
  final FocusNode orderIdFocusNode;
  final FocusNode phoneFocusNode;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: orderIdTextController,
      focusNode: orderIdFocusNode,
      nextFocus: phoneFocusNode,
      isShowBorder: true,
      hintText: getTranslated('order_id', context),
      prefixAssetUrl: Images.order,
      isShowPrefixIcon: true,
      suffixAssetUrl: Images.order,
      inputType: const TextInputType.numberWithOptions(decimal: false),

    );
  }
}