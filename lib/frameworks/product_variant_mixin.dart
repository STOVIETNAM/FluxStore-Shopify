import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools/tools.dart';
import '../generated/l10n.dart';
import '../models/index.dart'
    show CartModel, Product, ProductModel, ProductVariation;
import '../modules/firebase/firebase_analytics_service.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/detail/widgets/index.dart' show ProductShortDescription;
import '../services/service_config.dart';
import '../widgets/common/webview.dart';
import '../widgets/product/widgets/heart_button.dart';
import '../widgets/product/widgets/quantity_selection.dart';

mixin ProductVariantMixin {
  ProductVariation? updateVariation(
    List<ProductVariation> variations,
    Map<String?, String?> mapAttribute,
  ) {
    final templateVariation =
        variations.isNotEmpty ? variations.first.attributes : null;
    final listAttributes = variations.map((e) => e.attributes);

    ProductVariation productVariation;
    var attributeString = '';

    /// Flat attribute
    /// Example attribute = { "color": "RED", "SIZE" : "S", "Height": "Short" }
    /// => "colorRedsizeSHeightShort"
    templateVariation?.forEach((element) {
      final key = element.name;
      final value = mapAttribute[key];
      attributeString += value != null ? '$key$value' : '';
    });

    /// Find attributeS contain attribute selected
    final validAttribute = listAttributes.lastWhereOrNull(
      (attributes) =>
          attributes.map((e) => e.toString()).join().contains(attributeString),
    );

    if (validAttribute == null) return null;

    /// Find ProductVariation contain attribute selected
    /// Compare address because use reference
    productVariation =
        variations.lastWhere((element) => element.attributes == validAttribute);

    for (var element in productVariation.attributes) {
      if (!mapAttribute.containsKey(element.name)) {
        mapAttribute[element.name!] = element.option!;
      }
    }
    return productVariation;
  }

  bool isPurchased(
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?> mapAttribute,
    bool isAvailable,
  ) {
    var inStock;
    // ignore: unnecessary_null_comparison
    if (productVariation != null) {
      inStock = productVariation.inStock!;
    } else {
      inStock = product.inStock!;
    }

    var allowBackorder = productVariation != null
        ? (productVariation.backordersAllowed ?? false)
        : product.backordersAllowed;

    var isValidAttribute = false;
    try {
      if (product.attributes!.length == mapAttribute.length &&
          (product.attributes!.length == mapAttribute.length ||
              product.type != 'variable')) {
        isValidAttribute = true;
      }
    } catch (_) {}

    return (inStock || allowBackorder) && isValidAttribute && isAvailable;
  }

  List<Widget> makeProductTitleWidget(BuildContext context,
      ProductVariation? productVariation, Product product, bool isAvailable) {
    var listWidget = <Widget>[];

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    var stockQuantity =
        (kProductDetail.showStockQuantity) && product.stockQuantity != null
            ? '  (${product.stockQuantity}) '
            : '';
    if (Provider.of<ProductModel>(context, listen: false).selectedVariation !=
        null) {
      stockQuantity = (kProductDetail.showStockQuantity) &&
              Provider.of<ProductModel>(context, listen: false)
                      .selectedVariation!
                      .stockQuantity !=
                  null
          ? '  (${Provider.of<ProductModel>(context, listen: false).selectedVariation!.stockQuantity}) '
          : '';
    }

    if (isAvailable) {
      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if ((kProductDetail.showSku) &&
                product.sku != null &&
                product.sku != '') ...[
              Text(
                '${S.of(context).sku}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                product.sku!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: inStock
                          ? Theme.of(context).primaryColor
                          : const Color(0xFFe74c3c),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      );

      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if (kAdvanceConfig['showStockStatus']) ...[
              Text(
                '${S.of(context).availability}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              (productVariation != null
                      ? (productVariation.backordersAllowed ?? false)
                      : product.backordersAllowed)
                  ? Text(
                      S.of(context).backOrder,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: const Color(0xFFEAA601),
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : Text(
                      inStock
                          ? '${S.of(context).inStock}$stockQuantity'
                          : S.of(context).outOfStock,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: inStock
                                ? Theme.of(context).primaryColor
                                : const Color(0xFFe74c3c),
                            fontWeight: FontWeight.w600,
                          ),
                    )
            ],
          ],
        ),
      );

      if (product.shortDescription != null &&
          product.shortDescription!.isNotEmpty) {
        listWidget.add(
          ProductShortDescription(product),
        );
      }

      listWidget.add(
        const SizedBox(height: 15.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
      BuildContext context,
      ProductVariation? productVariation,
      Product product,
      Map<String?, String?>? mapAttribute,
      int maxQuantity,
      int quantity,
      Function addToCart,
      Function onChangeQuantity,
      bool isAvailable,
      {bool withQuantity = true}) {
    final theme = Theme.of(context);

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;
    var allowBackorder = productVariation != null
        ? (productVariation.backordersAllowed ?? false)
        : product.backordersAllowed;

    final isExternal = product.type == 'external' ? true : false;
    final isVariationLoading =
        // ignore: unnecessary_null_comparison
        (product.isVariableProduct || product.type == 'configurable') &&
            productVariation == null &&
            (mapAttribute?.isEmpty ?? true);

    final buyOrOutOfStockButton = Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isExternal
            ? ((inStock || allowBackorder) &&
                    (product.attributes!.length == mapAttribute!.length) &&
                    isAvailable)
                ? theme.primaryColor
                : theme.disabledColor
            : theme.primaryColor,
      ),
      child: Center(
        child: Text(
          ((((inStock || allowBackorder) && isAvailable) || isExternal) &&
                  !isVariationLoading
              ? S.of(context).buyNow
              : (isAvailable && !isVariationLoading
                      ? S.of(context).outOfStock
                      : isVariationLoading
                          ? S.of(context).loading
                          : S.of(context).unavailable)
                  .toUpperCase()),
          style: Theme.of(context).textTheme.button!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );

    if (!inStock && !isExternal && !allowBackorder) {
      return [
        GestureDetector(
          onTap: () {
            if ((((inStock || allowBackorder) && isAvailable) || isExternal) &&
                !isVariationLoading) {
            } else {
              //Show a toast message when the product is out of stock
              showFlash(
                context: context,
                duration: const Duration(seconds: 3),
                persistent: !Config().isBuilder,
                builder: (context, controller) {
                  return Flash(
                    borderRadius: BorderRadius.circular(3.0),
                    backgroundColor: Theme.of(context).primaryColor,
                    controller: controller,
                    behavior: FlashBehavior.floating,
                    position: FlashPosition.top,
                    horizontalDismissDirection:
                        HorizontalDismissDirection.horizontal,
                    child: FlashBar(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      title: Text(
                        S.of(context).outOfStock,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                        ),
                      ),
                      content: Text(
                        S.of(context).outOfStockMsg,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
          child: buyOrOutOfStockButton,
        ),
      ];
    }

    if ((product.isPurchased) && (product.isDownloadable ?? false)) {
      return [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async => await Tools.launchURL(product.files![0]!),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Text(
                    S.of(context).download,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return [
      if (!isExternal && kProductDetail.showStockQuantity && withQuantity) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).selectTheQuantity + ':',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Expanded(
              child: Container(
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: QuantitySelection(
                  height: 32.0,
                  expanded: true,
                  value: quantity,
                  color: theme.colorScheme.secondary,
                  limitSelectQuantity: maxQuantity,
                  onChanged: onChangeQuantity,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 10),

      /// Action Buttons: Buy Now, Add To Cart
      Row(
        children: <Widget>[
          HeartButton(
            product: product,
            size: 20,
          ),
          const SizedBox(width: 10),
          if (isAvailable &&
              (inStock || allowBackorder) &&
              !isExternal &&
              !isVariationLoading)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  addToCart(false, inStock || allowBackorder);
                  FirebaseAnalyticsService.addTocart({
                    'item': [
                      AnalyticsEventItem(
                          itemId: product.id,
                          itemName: product.name,
                          price: num.parse(num.parse(product.price.toString())
                              .toStringAsFixed(0)),
                          itemCategory: product.categoryName ?? '',
                          quantity: quantity)
                    ]
                  });
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Center(
                    child: Text(
                      S.of(context).addToCart.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: isAvailable
                  ? () => addToCart(true, inStock || allowBackorder)
                  : null,
              child: buyOrOutOfStockButton,
            ),
          ),
        ],
      )
    ];
  }

  /// Add to Cart & Buy Now function
  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation? productVariation, Map<String?, String?> mapAttribute,
      [bool buyNow = false, bool inStock = false]) {
    /// Out of stock || Variable product but not select any variant.
    if (!inStock || (product.isVariableProduct && mapAttribute.isEmpty)) {
      return;
    }

    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (product.type == 'external') {
      openWebView(context, product);
      return;
    }

    final _mapAttribute = Map<String, String>.from(mapAttribute);
    productVariation =
        Provider.of<ProductModel>(context, listen: false).selectedVariation;
    var message = cartModel.addProductToCart(
        context: context,
        product: product,
        quantity: quantity,
        variation: productVariation,
        options: _mapAttribute);

    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        persistent: !Config().isBuilder,
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).errorColor,
            controller: controller,
            behavior: FlashBehavior.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              content: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } else {
      if (buyNow) {
        Navigator.of(context).pushNamed(
          RouteList.cart,
          arguments: CartScreenArgument(isModal: true, isBuyNow: true),
        );
      }
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        persistent: !Config().isBuilder,
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).primaryColor,
            controller: controller,
            behavior: FlashBehavior.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              title: Text(
                product.name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              content: Text(
                S.of(context).addToCartSucessfully,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Text(S.of(context).notFound),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          url: product.affiliateUrl,
          title: product.name,
        ),
      ),
    );
  }
}
