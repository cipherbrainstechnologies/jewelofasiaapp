import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/data/model/social_login_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/screens/auth/widget/media_button_view.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginWidget extends StatefulWidget {
  final String? countryCode;
  const SocialLoginWidget({Key? key, required this.countryCode}) : super(key: key);

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();
  TextEditingController phoneController = TextEditingController();
  FocusNode focusNode = FocusNode();

  void route(
      bool isRoute,
      String? token,
      String? errorMessage,
      ) async {
    if (isRoute) {
      if(token != null){
        Navigator.pushNamedAndRemoveUntil(context, RouteHelper.menu, (route) => false, arguments: const MenuScreen());

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''),
            backgroundColor: Colors.red));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashProvider>(context,listen: false).configModel;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(children: [

          Center(child: Text(getTranslated('sign_in_with', context), style: poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6),
              fontSize: Dimensions.fontSizeSmall))),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            if(configModel!.socialLoginStatus!.isGoogle!) Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: MediaButtonView(
                image: Images.google,
                onTap: () async {
                  try{

                    GoogleSignInAuthentication  auth = await authProvider.googleLogin();
                    GoogleSignInAccount googleAccount = authProvider.googleAccount!;

                    Provider.of<AuthProvider>(Get.context!, listen: false).socialLogin(SocialLoginModel(
                      email: googleAccount.email, token: auth.idToken, uniqueId: googleAccount.id, medium: 'google',
                    ), route);


                  }catch(er){
                    debugPrint('access token error is : $er');
                  }
                },
              ),
            ),


            if(configModel.socialLoginStatus!.isFacebook!) MediaButtonView(
              image: Images.facebook,
              onTap: () async {
                LoginResult result = await FacebookAuth.instance.login();

                if (result.status == LoginStatus.success) {
                  Map userData = await FacebookAuth.instance.getUserData();

                  authProvider.socialLogin(
                    SocialLoginModel(
                      email: userData['email'],
                      token: result.accessToken!.token,
                      uniqueId: result.accessToken!.userId,
                      medium: 'facebook',
                    ), route,
                  );
                }
              },
            ),


            if(!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && configModel.appleLogin != null &&  configModel.appleLogin!.status!) Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: MediaButtonView(
                image: Images.appleLogo,
                onTap: () async {

                  final credential = await SignInWithApple.getAppleIDCredential(scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: '${configModel.appleLogin?.clientId}',
                      redirectUri: Uri.parse(AppConstants.baseUrl),
                    ),
                  );

                  

                  authProvider.socialLogin(SocialLoginModel(
                    email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: 'apple',
                  ), route);
                },
              ),
            ),





          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
        ]);
      }
    );
  }
}



