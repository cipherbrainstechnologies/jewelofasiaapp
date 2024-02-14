import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:flutter_grocery/view/screens/menu/web_menu/menu_screen_web.dart';
import 'package:flutter_grocery/view/screens/menu/widget/sign_out_confirmation_dialog.dart';

class ProfileHoverView extends StatelessWidget {
  const ProfileHoverView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MenuModel> list = [
      MenuModel(icon: Images.profile, title: getTranslated('profile', context), route: RouteHelper.profile),
      MenuModel(icon: Images.order, title: getTranslated('my_orders', context), route: RouteHelper.myOrder),
      MenuModel(icon: Images.profile, title: getTranslated('log_out', context), route: 'auth'),
    ];

    return Container(color: Theme.of(context).cardColor, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) => InkWell(
        onTap: (){
          if(item.route == 'auth'){
            Navigator.pop(context);



            Future.delayed(const Duration(seconds: 0), () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const SignOutConfirmationDialog(),
            ));


          }else{
            Navigator.pushNamed(context, item.route!);
          }

        },
        child: TextHover(builder: (isHover)=> Container(
          decoration: BoxDecoration(
            color: isHover ? Theme.of(context).focusColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              child: Text(item.title ?? '', overflow: TextOverflow.ellipsis, maxLines: 1, style: poppinsRegular),
            ),

            Divider(height: 1, color: (list.indexOf(item) + 1) != list.length ? Theme.of(context).dividerColor : Colors.transparent)

          ]),
        )),
      )).toList(),
    ));
  }
}
