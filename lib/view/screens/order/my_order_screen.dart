
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_view.dart';
import 'package:provider/provider.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> with TickerProviderStateMixin {

  TabController? _tabController;

  @override
  void initState() {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    Provider.of<OrderProvider>(context, listen: false).changeActiveOrderStatus(true, isUpdate: false);


    if(isLoggedIn) {
      _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();


    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone() ? null: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : const AppBarBase()) as PreferredSizeWidget?,

      body: isLoggedIn ? Consumer<OrderProvider>(
        builder: (context, orderProvider, child){
          return Column(
            children: [

              ResponsiveHelper.isDesktop(context) ? Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                child: Text("my_orders".tr, style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ) : const SizedBox(),

              Center(
                child: TabBar(
                  onTap: (int? index)=> orderProvider.changeActiveOrderStatus(index == 0),
                  tabAlignment: TabAlignment.center,
                  controller: _tabController,
                  labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  unselectedLabelStyle: poppinsRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  labelStyle: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  tabs: [
                    Tab(text: getTranslated('ongoing', context)),
                    Tab(text: getTranslated('history', context)),
                  ],
                ),
              ),

              Expanded(child: TabBarView(
                controller: _tabController,
                children: const [
                  OrderView(isRunning: true),
                  OrderView(isRunning: false),
                ],
              )),

            ],
          );

        }
      ) : const NotLoggedInScreen(),
    );
  }
}
// Provider.of<OrderProvider>(context, listen: false).runningOrderList != null ? ResponsiveHelper.isDesktop(context) ? FooterView() : SizedBox() : SizedBox(),




