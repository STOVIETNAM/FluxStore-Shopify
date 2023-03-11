import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/constants.dart';
import '../../../common/tools/flash.dart';
import '../../../models/index.dart' show Product, ProductWishListModel;
import '../../../models/user_model.dart';
import '../../../modules/firebase/firebase_analytics_service.dart';

class HeartButton extends StatelessWidget {
  final Product product;
  final double? size;
  final Color? color;

  const HeartButton({Key? key, required this.product, this.size, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ProductWishListModel>(context, listen: false),
      child: Consumer<ProductWishListModel>(
        builder: (BuildContext context, ProductWishListModel model, _) {
          final isExist =
              model.products.indexWhere((item) => item.id == product.id) != -1;
          if (!isExist) {
            return IconButton(
              onPressed: () async {
                var isUserLoggedIn =
                    Provider.of<UserModel>(context, listen: false).loggedIn;
                final prefs = await SharedPreferences.getInstance();
                if (!isUserLoggedIn && prefs.containsKey('userData')) {
                  isUserLoggedIn = true;
                }
                if (isUserLoggedIn) {
                  FirebaseAnalyticsService.addToWhish({
                    'item': [
                      AnalyticsEventItem(
                        itemId: product.id,
                        itemName: product.name,
                        price: num.parse(num.parse(product.price.toString())
                            .toStringAsFixed(0)),
                        itemCategory: product.categoryName ?? '',
                      )
                    ]
                  });
                  Provider.of<ProductWishListModel>(context, listen: false)
                      .addToWishlist(product);
                } else {
                  await FlashHelper.actionBar(
                    context,
                    title: 'Log In',
                    presistent: true,
                    duration: const Duration(seconds: 4),
                    message:
                        'You need to login first to add items to your wishlist.',
                    onPrimaryActionTap: (FlashController<dynamic> controller) {
                      Navigator.of(context).pushNamed(
                        RouteList.register,
                      );
                    },
                    primaryAction: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              },
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: Icon(
                  CupertinoIcons.heart,
                  color: color ?? Colors.grey.shade400,
                  size: size ?? 16.0,
                ),
              ),
            );
          }

          return IconButton(
            onPressed: () {
              Provider.of<ProductWishListModel>(context, listen: false)
                  .removeToWishlist(product);
            },
            icon: CircleAvatar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              child: Icon(CupertinoIcons.heart_fill,
                  color: Colors.pink, size: size ?? 16.0),
            ),
          );
        },
      ),
    );
  }
}
