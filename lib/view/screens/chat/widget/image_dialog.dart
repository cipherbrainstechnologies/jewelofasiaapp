import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';

class ImageDialog extends StatelessWidget {
  final String imageUrl;
  const ImageDialog({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).primaryColor.withOpacity(0.20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  placeholder: Images.getPlaceHolderImage(context), image: imageUrl, fit: BoxFit.contain,
                  imageErrorBuilder: (c, o, s) => Image.asset(
                    Images.getPlaceHolderImage(context), height: MediaQuery.of(context).size.width - 130,
                    width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

          ],
        ),
      ),
    );
  }
}