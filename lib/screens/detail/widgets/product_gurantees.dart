import 'package:flutter/material.dart';
import 'product_appbar_image_button.dart';

class ProductGuarantees extends StatelessWidget {
  const ProductGuarantees({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProductAppBarImageButton(
                icon: 'assets/images/delivery_icon.png',
                onTap: () {},
                title: 'Pan India Delivery',
              ),
              ProductAppBarImageButton(
                icon: 'assets/images/warranty_icon.png',
                onTap: () {},
                title: 'On-site Warranty',
              ),
              ProductAppBarImageButton(
                icon: 'assets/images/return_icon.png',
                onTap: () {},
    
                title: 'Easy Returns',
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
