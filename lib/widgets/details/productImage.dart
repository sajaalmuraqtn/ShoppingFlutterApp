import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final Size size;
  final String image;

  const ProductImage({super.key, required this.size, required this.image});

  @override
  Widget build(BuildContext context) {
    Widget displayedImage;

    if (image.contains('assets/')) {
      displayedImage = Image.asset(
        image,
        height: 300,
        fit: BoxFit.contain,
      );
    } else if (Uri.tryParse(image)?.isAbsolute ?? false) {
      displayedImage = Image.network(
        image,
        height: 300,
        fit: BoxFit.contain,
      );
    } else {
      displayedImage = Container(
        height: 250,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Text(
          "لا توجد صورة",
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      height: size.width * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size.width * 0.7,
            width: size.width * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          displayedImage,
        ],
      ),
    );
  }
}
