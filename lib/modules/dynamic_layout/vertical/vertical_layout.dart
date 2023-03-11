import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../services/index.dart';
import '../../../widgets/product/product_simple_view.dart';
import '../config/product_config.dart';
import '../helper/helper.dart';

class VerticalViewLayout extends StatefulWidget {
  final ProductConfig config;

  const VerticalViewLayout({required this.config, Key? key}) : super(key: key);

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<VerticalViewLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;
  bool loading = false;

  void _loadProduct() async {
    if (loading) return;
    var config = widget.config.toJson();
    _page = _page + 1;
    config['page'] = _page;
    if (!canLoad) return;
    loading = true;
    var newProducts = await _service.api.fetchProductsLayout(
        config: config,
        lang: Provider.of<AppModel>(context, listen: false).langCode);
    if (newProducts == null || newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    if (newProducts != null && newProducts.isNotEmpty) {
      setState(() {
        _products = [..._products, ...newProducts];
      });
    }
    loading = false;
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    var widthContent = 0;
    final isTablet = Helper.isTablet(MediaQuery.of(context));

    if (widget.config.layout == 'card') {
      widthContent = 1; //one column
    } else if (widget.config.layout == 'columns') {
      widthContent = isTablet ? 4 : 3; //three columns
    } else {
      //layout is list
      widthContent = isTablet ? 3 : 2; //two columns
    }
    // ignore: division_optimization
    var rows = (_products.length / widthContent).toInt();
    if (rows * widthContent < _products.length) rows++;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: widget.config.vPadding,
              horizontal: widget.config.hPadding,
            ),
            cacheExtent: 1500,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              if (widget.config.layout == 'list') {
                return ProductSimpleView(
                  item: _products[index],
                  type: SimpleType.backgroundColor,
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widthContent, (child) {
                  return Expanded(
                    child: index * widthContent + child < _products.length
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Services().widget.renderProductCardView(
                                  item: _products[index * widthContent + child],
                                  width: constraints.maxWidth,
                                  config: widget.config,
                                  ratioProductImage: widget.config.imageRatio
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                  );
                }),
              );
            }),
        VisibilityDetector(
          key: const Key('loading_vertical'),
          onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
          child: !canLoad
              ? const SizedBox()
              : Center(
                  child: Text(S.of(context).loading),
                ),
        )
      ],
    );
  }
}
