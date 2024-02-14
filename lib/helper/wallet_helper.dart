import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/wallet_filter_body.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/styles.dart';

class WalletHelper {
  static List<PopupMenuEntry> getPopupMenuList({required List<WalletFilterBody> walletFilterList, required String? type}){
    List<PopupMenuEntry> entryList = [];

    for(int i = 0; i < walletFilterList.length; i++){
      entryList.add(PopupMenuItem<int>(value: i, child: Text(
        getTranslated(walletFilterList[i].title!, Get.context!),
        style: poppinsMedium.copyWith(
          color: walletFilterList[i].value == type
              ? Theme.of(Get.context!).textTheme.bodyMedium!.color
              : Theme.of(Get.context!).disabledColor,
        ),
      )));
    }
    return entryList;
  }
}