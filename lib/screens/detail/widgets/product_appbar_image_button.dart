import 'package:flutter/material.dart';

class ProductAppBarImageButton extends StatelessWidget {
  final String icon;
  final String title;
  final Function onTap;
  final double? height;
  const ProductAppBarImageButton(
      {required this.icon,
      required this.title,
      required this.onTap,
      Key? key,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as VoidCallback,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: height ?? MediaQuery.of(context).size.width * .15,
            height: height ?? MediaQuery.of(context).size.width * .15,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
