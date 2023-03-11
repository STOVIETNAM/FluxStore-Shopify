import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/entities/index.dart' show AddonsOption;
import '../../models/index.dart' show AppModel, Product, ProductVariation;
import '../../services/index.dart';
import 'widgets/quantity_selection.dart';

class ShoppingCartRow extends StatelessWidget {
  const ShoppingCartRow({
    required this.product,
    required this.quantity,
    this.onRemove,
    this.onChangeQuantity,
    this.variation,
    this.options,
    this.addonsOptions,
  });

  final Product? product;
  final List<AddonsOption>? addonsOptions;
  final ProductVariation? variation;
  final Map<String, dynamic>? options;
  final int? quantity;
  final Function? onChangeQuantity;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    print("====> ${product!.regularPrice}");
    var currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    final price = Services().widget.getPriceItemInCart(
        product!, variation, currencyRate, currency,
        selectedOptions: addonsOptions);

    final imageFeature = variation != null && variation!.imageFeature != null
        ? variation!.imageFeature
        : product!.imageFeature;
    var maxQuantity = kCartDetail['maxAllowQuantity'] ?? 100;
    var totalQuantity = variation != null
        ? (variation!.stockQuantity ?? maxQuantity)
        : (product!.stockQuantity ?? maxQuantity);
    var limitQuantity =
        totalQuantity > maxQuantity ? maxQuantity : totalQuantity;

    var theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxWidth * 0.35,
              child: Row(
                key: ValueKey(product!.id),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if (onRemove != null)
                  //   IconButton(
                  //     icon: const Icon(Icons.remove_circle_outline),
                  //     onPressed: onRemove,
                  //   ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: constraints.maxWidth * 0.30,
                          height: constraints.maxWidth * 0.35,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ImageTools.image(
                              url: imageFeature,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product!.name!,
                                style: const TextStyle(
                                    color: kColorBackCouponTitle9,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 7),

                              Row(
                                children: [
                                  Text(
                                    '${price!}  ',
                                    style: const TextStyle(
                                        color: kColorBackCouponTitle10,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12),
                                  ),
                                  Text(
                                      PriceTools.getCurrencyFormatted(
                                        product!.regularPrice,
                                        currencyRate,
                                        currency: currency,
                                      )!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: kColorBackCouponTitle11,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // if (product!.options != null && options != null)
                              //   Services()
                              //       .widget
                              //       .renderOptionsCartItem(product!, options),
                              // if (variation != null)
                              //   Services().widget.renderVariantCartItem(
                              //       context, variation!, options),
                              // if (addonsOptions?.isNotEmpty ?? false)
                              //   Services().widget.renderAddonsOptionsCartItem(
                              //       context, addonsOptions),
                              if (kProductDetail.showStockQuantity)
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 18,
                                        // width: 85,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 10,
                                                  color: Colors.black
                                                      .withOpacity(.27))
                                            ]),
                                        child: Row(
                                          children: [
                                            const Spacer(),
                                            const Text(
                                              'Size: 14 Inch',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: kColorBackCouponTitle9,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const Spacer(),
                                            Image.asset(
                                              arrowDown,
                                              height: 8,
                                              width: 8,
                                            ),
                                            // Icon(Icons.keyboard_arrow_down,
                                            //     size: 14, color: Theme.of(context).colorScheme.secondary),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Expanded(
                                      flex: 2,
                                      child: QuantitySelection(
                                        isFromCart: true,
                                        enabled: onChangeQuantity != null,
                                        width: 60,
                                        height: 32,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        limitSelectQuantity: limitQuantity,
                                        value: quantity,
                                        onChanged: onChangeQuantity,
                                        useNewDesign: false,
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                  ],
                                ),
                              if (product?.store != null &&
                                  (product?.store?.name != null &&
                                      product!.store!.name!.trim().isNotEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    product!.store!.name!,
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 10.0),
            // const Divider(color: kGrey200, height: 1),
            const SizedBox(height: 15.0),
          ],
        );
      },
    );
  }
}
