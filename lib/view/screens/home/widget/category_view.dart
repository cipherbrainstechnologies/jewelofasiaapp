import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/screens/home/web/web_categories.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, category, child) {

        return category.categoryList != null
            ? Column(
          children: [

            TitleWidget(title: getTranslated('popular_categories', context)),

            ResponsiveHelper.isDesktop(context) ? const CategoriesWebView() : GridView.builder(
              itemCount: category.categoryList!.length > 7 ? 8 : category.categoryList!.length,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isMobilePhone() ? 4 : ResponsiveHelper.isTab(context) ? 4 :3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                return Center(
                  child: InkWell(
                    onTap: () {
                      if (index == 7) {
                        ResponsiveHelper.isMobilePhone() ? Provider.of<SplashProvider>(context, listen: false).setPageIndex(1) : const SizedBox();
                        ResponsiveHelper.isWeb() ? Navigator.pushNamed(context, RouteHelper.categories) : const SizedBox();

                      } else {
                        Provider.of<CategoryProvider>(context, listen: false).changeSelectedIndex(-1,notify: false);
                        Navigator.of(context).pushNamed(
                          RouteHelper.getCategoryProductsRouteNew(categoryId: '${category.categoryList![index].id}'),
                        );
                      }
                    },
                    child: Column(children: [
                      Expanded(
                        flex: ResponsiveHelper.isDesktop(context) ? 7 : 6,
                        child: Container(
                          margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          //padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                          ),
                          child: index != 7 ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: CustomImage(
                                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${category.categoryList![index].image}',
                                fit: BoxFit.cover, height: 70, width: 70,
                              ),
                            ),
                          ) : Container(
                            height: 70, width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            alignment: Alignment.center,
                            child: Text('${category.categoryList!.length - 7}+', style: poppinsRegular.copyWith(color: Theme.of(context).cardColor)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: ResponsiveHelper.isDesktop(context) ? 3 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Text(
                            index != 7 ? category.categoryList![index].name! : getTranslated('view_all', context),
                            style: poppinsRegular,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ],
        ) : const CategoriesShimmer();
      },
    );
  }
}

class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      //physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1 / 1.1) : (1 / 1.2),
        crossAxisCount: ResponsiveHelper.isWeb()?6:ResponsiveHelper.isMobilePhone()?3:ResponsiveHelper.isTab(context)?4:3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(Provider.of<ThemeProvider>(context).darkTheme ? 0.05 : 1),
            boxShadow: Provider.of<ThemeProvider>(context).darkTheme ? null : [BoxShadow(color: Colors.grey[200]!, spreadRadius: 1, blurRadius: 5)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: Provider.of<CategoryProvider>(context).categoryList == null,
            child: Column(children: [
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeLarge),
                  child: Container(color: Colors.grey[300], width: 50, height: 10),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
