import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:provider/provider.dart';


class CategoryPageView extends StatelessWidget {
  final CategoryProvider categoryProvider;
  final ScrollController? scrollController;
  const CategoryPageView({Key? key, required this.categoryProvider, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: categoryProvider.categoryList!.length,
      scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeDefault),
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: (){
                Navigator.of(context).pushNamed(RouteHelper.getCategoryProductsRouteNew(categoryId: '${categoryProvider.categoryList![index].id}'));
              },
              child: TextHover(
                  builder: (hovered) {
                    return Column(children: [
                      OnHover(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(Provider.of<ThemeProvider>(context).darkTheme ? 0.05 : 1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CustomImage(
                              image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                  ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${categoryProvider.categoryList![index].image}':'',
                              height: 100, width: 100, fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),


                      SizedBox(
                        width: 110,
                        child: Text(
                          categoryProvider.categoryList![index].name!,
                          style: poppinsMedium.copyWith(color: hovered ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ]);
                  }
              ),
            ),
          );
        },
    );
  }
}
