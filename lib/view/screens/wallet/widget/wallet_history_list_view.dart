import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/wallet_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/screens/wallet/widget/history_item.dart';
import 'package:flutter_grocery/view/screens/wallet/widget/wallet_shimmer.dart';
import 'package:provider/provider.dart';


class WalletHistoryListView extends StatelessWidget {
  const WalletHistoryListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Consumer<WalletProvider>(builder: (context, walletProvider, _) => Center(child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Column(children: [
          Column(children: [

            walletProvider.transactionList != null ? walletProvider.transactionList!.isNotEmpty ? ListView.builder(
              key: UniqueKey(),
              physics:  const NeverScrollableScrollPhysics(),
              shrinkWrap:  true,
              itemCount: walletProvider.transactionList!.length ,
              itemBuilder: (context, index) => WalletHistory(transaction: walletProvider.transactionList![index]),
            ) : NoDataScreen(isFooter: false, title: getTranslated('no_result_found', context),) : WalletShimmer(isEnable: walletProvider.transactionList == null),

            walletProvider.paginationLoader ? Center(child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomLoader(color: Theme.of(context).primaryColor),
            )) : const SizedBox(),
          ])
        ]),
      ))),
    );
  }
}

