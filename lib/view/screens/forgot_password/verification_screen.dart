import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/model/response/signup_model.dart';
import 'package:flutter_grocery/helper/app_mode.dart';
import 'package:flutter_grocery/helper/email_checker.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/forgot_password/create_new_password_screen.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../base/footer_view.dart';
import '../../base/web_app_bar/web_app_bar.dart';

class VerificationScreen extends StatefulWidget {
  final String? emailAddress;
  final String? session;
  final bool fromSignUp;
  const VerificationScreen({Key? key, this.emailAddress, this.fromSignUp = false, this.session}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  @override
  void initState() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.startVerifyTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final isPhone = EmailChecker.isNotValid(widget.emailAddress!);

    final ConfigModel config = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final bool isFirebaseOTP =  config.customerVerification!.status! && config.customerVerification?.type ==  'firebase';

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : CustomAppBar(
        title: getTranslated(isPhone ? 'verify_phone' : 'verify_email', context),
      )) as PreferredSizeWidget?,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
                  child: SizedBox(
                    width: 1170,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) =>
                          Container(
                            margin: EdgeInsets.only(top: width > 700 ? 55 : 0,bottom: width > 700 ? 55 : 0),
                            decoration: width > 700 ? BoxDecoration(
                              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 1)],
                            ) : null,
                            child: Column(
                              children: [
                                const SizedBox(height: 55),

                                Image.asset(
                                  Images.emailWithBackground,
                                  width: 142, height: 142,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 40),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 50),
                                  child: Center(
                                      child: Text(
                                        '${getTranslated('please_enter', context)} 6 ${getTranslated('digit_code', context)} '
                                            '\n ${widget.emailAddress!.trim()}',
                                        textAlign: TextAlign.center,
                                        style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                                      )),
                                ),

                                if(AppMode.demo == AppConstants.appMode && !isFirebaseOTP)
                                  Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    child: Text(getTranslated('for_demo_purpose_use', context), style: poppinsMedium.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    )),
                                  ),

                                Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: width > 850 ? 300 : 39, vertical: 35),
                                  child: PinCodeTextField(
                                    length: 6,
                                    appContext: context,
                                    obscureText: false,
                                    enabled: true,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      fieldHeight: 63,
                                      fieldWidth: 52,
                                      borderWidth: 1,
                                      borderRadius: BorderRadius.circular(10),
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(.2),
                                      selectedFillColor: Colors.white,
                                      inactiveFillColor: Theme.of(context).cardColor,
                                      inactiveColor: Theme.of(context).primaryColor.withOpacity(.2),
                                      activeColor: Theme.of(context).primaryColor.withOpacity(.4),
                                      activeFillColor: Theme.of(context).cardColor,
                                    ),
                                    animationDuration: const Duration(milliseconds: 300),
                                    backgroundColor: Colors.transparent,
                                    enableActiveFill: true,
                                    onChanged: (query)=> authProvider.updateVerificationCode(query, 6),
                                    beforeTextPaste: (text) {
                                      return true;
                                    },
                                  ),
                                ),



                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(getTranslated('did_not_receive_the_code', context), style: poppinsMedium.copyWith(
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.6),
                                    )),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),


                                    authProvider.resendButtonLoading ?
                                    CustomLoader(color: Theme.of(context).primaryColor) :
                                    TextButton(
                                        onPressed: authProvider.currentTime! > 0 ? null :  () async {
                                           if (widget.fromSignUp) {
                                            await authProvider.sendVerificationCode(config, SignUpModel(phone: widget.emailAddress, email: widget.emailAddress));

                                          } else {
                                            if(isFirebaseOTP) {
                                              authProvider.firebaseVerifyPhoneNumber('${widget.emailAddress?.trim()}', isForgetPassword: true);
                                            }else{
                                              await authProvider.forgetPassword(widget.emailAddress).then((value) {
                                                authProvider.startVerifyTimer();

                                                if (value.isSuccess) {
                                                  showCustomSnackBar('resend_code_successful', isError: false);
                                                } else {
                                                  showCustomSnackBar(value.message!);
                                                }
                                              });
                                            }
                                          }

                                        },
                                        child: Builder(
                                            builder: (context) {
                                              int? days, hours, minutes, seconds;

                                              Duration duration = Duration(seconds: authProvider.currentTime ?? 0);
                                              days = duration.inDays;
                                              hours = duration.inHours - days * 24;
                                              minutes = duration.inMinutes - (24 * days * 60) - (hours * 60);
                                              seconds = duration.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);

                                              return CustomDirectionality(
                                                child: Text((authProvider.currentTime != null && authProvider.currentTime! > 0)
                                                    ? '${getTranslated('resend', context)} (${minutes > 0 ? '${minutes}m :' : ''}${seconds}s)'
                                                    : getTranslated('resend_it', context), textAlign: TextAlign.end,
                                                    style: poppinsMedium.copyWith(
                                                      color: authProvider.currentTime != null && authProvider.currentTime! > 0 ?
                                                      Theme.of(context).disabledColor : Theme.of(context).primaryColor.withOpacity(.6),
                                                    )),
                                              );
                                            }
                                        )),
                                  ],
                                ) ,
                                const SizedBox(height: 48),

                                authProvider.isEnableVerificationCode && !authProvider.resendButtonLoading ? !authProvider.isPhoneNumberVerificationButtonLoading ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                  child: CustomButton(
                                    buttonText: getTranslated('verify', context),
                                    onPressed: () {
                                      if (widget.fromSignUp) {
                                        if(config.customerVerification!.status! && config.customerVerification!.type == 'phone') {
                                          authProvider.verifyPhone(widget.emailAddress!.trim()).then((value) {
                                            if(value.isSuccess){
                                              Navigator.pushNamedAndRemoveUntil(context, RouteHelper.menu, (route) => false, arguments: const MenuScreen());
                                            }
                                          });
                                        }else if(config.customerVerification!.status! && config.customerVerification!.type == 'email') {
                                          authProvider.verifyEmail(widget.emailAddress).then((value){
                                            if(value.isSuccess){
                                              Navigator.pushNamedAndRemoveUntil(context, RouteHelper.menu, (route) => false, arguments: const MenuScreen());
                                            }

                                          });

                                        } else if(isFirebaseOTP) {
                                          authProvider.firebaseOtpLogin(
                                            phoneNumber: '${widget.emailAddress}',
                                            session: '${widget.session}',
                                            otp: authProvider.verificationCode,
                                          );

                                        }
                                      } else {
                                        if(isFirebaseOTP) {
                                          authProvider.firebaseOtpLogin(
                                            phoneNumber: '${widget.emailAddress}',
                                            session: '${widget.session}',
                                            otp: authProvider.verificationCode,
                                            isForgetPassword: true,
                                          );
                                        }else{
                                          authProvider.verifyToken(widget.emailAddress).then((value) {
                                            if(value.isSuccess) {
                                              Navigator.of(context).pushNamed(
                                                RouteHelper.getNewPassRoute(widget.emailAddress, authProvider.verificationCode),
                                                arguments: CreateNewPasswordScreen(email: widget.emailAddress, resetToken: authProvider.verificationCode),
                                              );
                                            }else {
                                              showCustomSnackBar(value.message!);
                                            }
                                          });
                                        }

                                      }
                                    },
                                  ),
                                )
                                    : Center(child: CustomLoader(color: Theme.of(context).primaryColor))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 48),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),

                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
              ])),
        ),
      ),
    );
  }
}
