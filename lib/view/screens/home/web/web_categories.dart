import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_view.dart';
import 'package:provider/provider.dart';

import 'arrow_button.dart';
import 'category_page_view.dart';
class CategoriesWebView extends StatefulWidget {
  const CategoriesWebView({Key? key}) : super(key: key);

  @override
  State<CategoriesWebView> createState() => _CategoriesWebViewState();
}

class _CategoriesWebViewState extends State<CategoriesWebView> {

  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CategoryProvider>(builder: (context,category,child){

      if(category.categoryList != null && category.categoryList!.length > 9 && isFirstTime){
        showForwardButton = true;
        isFirstTime = false;
      }

      return category.categoryList != null?
      Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 210,
                  child:  category.categoryList != null ? category.categoryList!.isNotEmpty ?
                  CategoryPageView(categoryProvider: category, scrollController: scrollController)
                      : Center(child: Text(getTranslated('no_category_available', context))) : const CategoriesShimmer(),

                ),
              ),
            ],
          ),

          if(showBackButton && ResponsiveHelper.isDesktop(context))
            Positioned(
              top: 50, left: 0,
              child: ArrowIconButton(
                isRight: false,
                onTap: () => scrollController.animateTo(scrollController.offset - Dimensions.webScreenWidth,
                    duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
              ),
            ),

          if(showForwardButton && ResponsiveHelper.isDesktop(context))
            Positioned(
              top: 50, right: 0,
              child: ArrowIconButton(
                onTap: () => scrollController.animateTo(scrollController.offset + Dimensions.webScreenWidth,
                    duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
              ),
            ),

        ],
      ): const SizedBox();
    });
  }
}
