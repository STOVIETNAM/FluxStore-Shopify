import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools/price_tools.dart';
import '../../../models/app_model.dart';
import '../../../models/entities/product.dart';
import '../../../services/services.dart';

class ShortProductInfo extends StatelessWidget {
  final Product product;
  const ShortProductInfo({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: NetworkImage(
                product.images[0],
              ))),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(product.name!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Services()
                        .widget
                        .renderDetailPrice(context, product, product.price),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      PriceTools.getCurrencyFormatted(
                        product.regularPrice,
                        Provider.of<AppModel>(context).currencyRate,
                        currency: Provider.of<AppModel>(context).currency,
                      )!,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  ],
                ),
                product.attributes != null
                    ? product.attributes![0].options != null
                        ? Text(
                            product.attributes![0].options![0]
                                    .toString()
                                    .contains('Default')
                                ? ''
                                : product.attributes![0].options![0].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300),
                          )
                        : Container()
                    : Container()
              ]),
        )
      ]),
    );
  }
}
