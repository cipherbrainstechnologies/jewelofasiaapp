import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/wish_button.dart';
import 'package:flutter_grocery/view/screens/product/image_zoom_screen.dart';
import 'package:provider/provider.dart';

class ProductImageView extends StatelessWidget {
  final Product? productModel;
  const ProductImageView({Key? key, required this.productModel}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(children: [
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              RouteHelper.getProductImagesRoute(productModel!.name, jsonEncode(productModel!.image)),
              arguments: ProductImageScreen(imageList: productModel!.image, title: productModel!.name),
            ),

            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: ResponsiveHelper.isDesktop(context) ? 350 : MediaQuery.of(context).size.height * 0.4,
                  child: PageView.builder(
                    itemCount: productModel!.image!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CustomImage(
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${productModel!.image![cartProvider.productSelect]}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      Provider.of<CartProvider>(context, listen: false).setSelect(index, true);
                      Provider.of<ProductProvider>(context, listen: false).setImageSliderSelectedIndex(index);
                    },
                  ),
                );
              }
            ),
          ),

          Positioned(
            top: 26, right: 26,
            child: WishButton(product: productModel, edgeInset: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)),
          )

        ]),
      ],
    );
  }

}
