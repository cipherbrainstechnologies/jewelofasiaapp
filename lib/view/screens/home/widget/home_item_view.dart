import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:provider/provider.dart';

class HomeItemView extends StatelessWidget {
  final List<Product>? productList;
  final bool isFlashDeal;
  final bool isFeaturedItem;

  const HomeItemView({Key? key, this.productList, this.isFlashDeal = false, this.isFeaturedItem = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<FlashDealProvider>(builder: (context, flashDealProvider, child) {
        return Consumer<ProductProvider>(builder: (context, productProvider, child) {


          return productList != null ? Column(children: [
              isFlashDeal ? SizedBox(
              height: 340,
              child: CarouselSlider.builder(
                itemCount: productList!.length,
                options: CarouselOptions(
                  height: 340,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: 0.6,
                  enlargeFactor: 0.2,
                  onPageChanged: (index, reason) {
                    flashDealProvider.setCurrentIndex(index);
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return ProductWidget(
                    isGrid: true,
                    product: productList![index],
                    productType: ProductType.flashSale,
                  );
                },
              )) : SizedBox(
                height: isFeaturedItem ? 150 : 340,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall),
                  itemCount: productList!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      width: ResponsiveHelper.isDesktop(context) ? isFeaturedItem ? 370 : 260 : isFeaturedItem ? MediaQuery.of(context).size.width * 0.90 : MediaQuery.of(context).size.width * 0.65,
                      padding: const EdgeInsets.all(5),
                      child: ProductWidget(
                        isGrid: isFeaturedItem ? false : true,
                        product: productList![index],
                        productType: ProductType.dailyItem,
                      ),
                    );
                    },
                ),
              ),
          ]) : SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 195,
                  padding: const EdgeInsets.all(5),
                  child: const WebProductShimmer(isEnabled: true),
                );
              },
            ),
          );
        });
      }
    );
  }
}



