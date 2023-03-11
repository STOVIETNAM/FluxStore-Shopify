import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../modules/dynamic_layout/config/product_config.dart';
import '../routes/flux_navigate.dart';
import '../services/index.dart';
import 'entities/back_drop_arguments.dart';
import 'entities/product.dart';
import 'entities/product_variation.dart';

class ProductModel with ChangeNotifier {
  final Services _service = Services();
  List<List<Product?>> products = [];
  String? message;

  /// current select product id/name
  String? categoryId;
  String? listingLocationId;
  String? categoryName;
  int? tagId;

  //list products for products screen
  bool isFetching = false;
  List<Product>? productsList;
  String? errMsg;
  bool? isEnd;

  List<ProductVariation> variations = [];
  List<String> variationsFeatureImages = [];
  ProductVariation? selectedVariation;
  List<Product>? lstGroupedProduct;
  String? cardPriceRange;
  String detailPriceRange = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void clearProductVariations() {
    variations.clear();
    variationsFeatureImages = [];
    selectedVariation = null;
    notifyListeners();
  }

  void changeSelectedVariation(ProductVariation? variation) {
    selectedVariation = variation;

    if (kProductDetail.showSelectedImageVariant) {
      eventBus.fire(EventChangeSelectedVariation(variation));
    }
    notifyListeners();
  }

  void changeProductVariations(List<ProductVariation> newVariations) {
    variationsFeatureImages = [];
    variations.clear();
    variations.addAll(newVariations);
    variationsFeatureImages
        .addAll(variations.map((e) => e.imageFeature).whereType<String>());
    notifyListeners();
  }

  void setCategoryName(String? name) {
    categoryName = name;
  }

  Future<List<Product>?> fetchGroupedProducts(
      {required Product product}) async {
    lstGroupedProduct = [];
    for (var productID in product.groupedProducts as Iterable<int>) {
      await _service.api.getProduct(productID)!.then((product) {
        if (product != null) {
          lstGroupedProduct!.add(product);
        }
      });
    }
    return lstGroupedProduct;
  }

  void changeDetailPriceRange(String? currency, Map<String, dynamic> rates) {
    if (lstGroupedProduct!.isNotEmpty) {
      var currentPrice = double.parse(lstGroupedProduct![0].price!);
      var max = currentPrice;
      var min = 0;
      for (var product in lstGroupedProduct!) {
        min = double.parse(product.price!).toInt();
        if (min > max) {
          var temp = min;
          max = min.toDouble();
          min = temp;
        }
        detailPriceRange = currentPrice != max
            ? '${PriceTools.getCurrencyFormatted(currentPrice, rates, currency: currency)} - ${PriceTools.getCurrencyFormatted(max, rates, currency: currency)}'
            : PriceTools.getCurrencyFormatted(currentPrice, rates,
                    currency: currency)
                .toString();
      }
    }
  }

  Future<List<Product>?> fetchProductLayout(config, lang, {userId}) async {
    return _service.api
        .fetchProductsLayout(config: config, lang: lang, userId: userId);
  }

  void fetchProductsByCategory({
    categoryId,
    categoryName,
    listingLocationId,
    bool notify = true,
  }) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    this.listingLocationId = listingLocationId;
    if (notify) notifyListeners();
  }

  void updateTagId({tagId, bool notify = true}) {
    this.tagId = int.tryParse(tagId.toString());
    if (notify) notifyListeners();
  }

  Future<void> saveProducts(Map<String, dynamic> data) async {
    final storage = injector<LocalStorage>();
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['home']!, data);
      }
    } catch (_) {}
  }

  Future<void> getProductsList({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    String? tagId,
    lang,
    required page,
    featured,
    onSale,
    attribute,
    attributeTerm,
    listingLocation,
    userId,
    List? include,
  }) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      if (tagId != null && tagId.isNotEmpty) {
        this.tagId = int.tryParse(tagId);
      }
      if (listingLocation != null) {
        listingLocationId = listingLocation;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();
      String? cursor;
      if (Config().isNotion && (productsList?.isNotEmpty ?? false)) {
        if (page == 1) {
          cursor = null;
        } else {
          cursor = productsList!.last.id;
        }
      }

      final products = await _service.api.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm,
        listingLocation: listingLocation,
        userId: userId,
        nextCursor: cursor,
        include: include?.join(','),
      );

      isEnd = products!.isEmpty || products.length < apiPageSize;

      if (page == 0 || page == 1) {
        productsList = products;
      } else {
        productsList = [...productsList!, ...products];
      }

      isFetching = false;
      errMsg = null;

      notifyListeners();
    } catch (err, trace) {
      errMsg =
          'There is an issue with the app during request the data, please contact admin for fixing the issues ' +
              err.toString();
      isFetching = false;
      printLog(err);
      printLog(trace);
      notifyListeners();
    }
  }

  void setProductsList(List<Product> products, {bool notify = true}) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    if (notify) notifyListeners();
  }

  Future<void> createProduct(
      List galleryImages,
      List<File> fileImages,
      String? cookie,
      String nameProduct,
      String? type,
      String? idCategory,
      double? salePrice,
      double regularPrice,
      String description) async {
    Future uploadImage() async {
      try {
        if (fileImages.isNotEmpty) {
          for (var i = 0; i < fileImages.length; i++) {
            printLog('path ${path.basename(fileImages[i].path)}');
            await _service.api.uploadImage({
              'title': {'rendered': path.basename(fileImages[i].path)},
              'media_attachment': base64.encode(fileImages[i].readAsBytesSync())
            }, cookie)!.then((photo) {
              galleryImages.add('${photo['id']}');
            });
          }
        } else {
          return;
        }
      } catch (e) {
        rethrow;
      }
    }

    await uploadImage().then((_) async {
      await _service.api.createProduct(cookie, {
        'title': nameProduct,
        'product_type': type,
        'content': description,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'image_ids': galleryImages,
        'categories': [
          {'id': idCategory}
        ],
        'status': kNewProductStatus
      });
    });
  }

  Future<void> deleteProduct({
    required String? productId,
    required String? cookie,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _service.api.deleteProduct(cookie: cookie, productId: productId);
    _isLoading = false;
    notifyListeners();
  }

  /// Show the product list
  // ignore: missing_return
  static Future showList({
    cateId,
    cateName,
    String? tag,
    required BuildContext context,
    List<Product>? products,
    config,
    bool showCountdown = false,
    Duration countdownDuration = Duration.zero,
  }) async {
    try {
      var _config = config != null
          ? ProductConfig.fromJson(config)
          : ProductConfig.empty();

      var categoryId = cateId ?? _config.category;
      var categoryName = cateName ?? _config.name;
      // var featured = _config.featured;
      var listingLocationId = config?['location']?.toString();
      final bool? onSale = _config.onSale;
      final configCountdown = _config.showCountDown;
      var backgroundColor = _config.backgroundColor;

      var tagId = tag ?? config?['tag']?.toString();
      final productModel = Provider.of<ProductModel>(context, listen: false);

      if (kIsWeb || isDisplayDesktop(context)) {
        eventBus.fire(const EventCloseCustomDrawer());
      } else {
        eventBus.fire(const EventCloseNativeDrawer());
      }

      // for fetching beforehand
      if (categoryId != null || listingLocationId != null) {
        productModel.fetchProductsByCategory(
          categoryId: categoryId,
          categoryName: categoryName,
          listingLocationId: listingLocationId,
        );
      } else {
        productModel.setCategoryName(null);
      }

      var productConfig = ProductConfig.fromJson(config ?? {})
        ..backgroundColor = backgroundColor
        ..category = categoryId
        ..tag = tagId
        ..onSale = onSale ?? false
        ..featured = _config.featured
        ..name = Config().isListingType
            ? categoryName
            : (onSale ?? false) && showCountdown
                ? categoryName
                : null
        ..showCountDown = configCountdown && (onSale ?? false) && showCountdown;

      /// for caching current products list from HomeCache
      if (products != null && products.isNotEmpty) {
        productModel.setProductsList(products);

        return FluxNavigate.pushNamed(
          RouteList.backdrop,
          arguments: BackDropArguments(
            config: productConfig.toJson(),
            data: products,
            countdownDuration: countdownDuration,
          ),
        );
      }

      /// clear old products
      productModel.setProductsList([]);
      productModel.updateTagId(tagId: config != null ? config['tag'] : null);
      await FluxNavigate.pushNamed(
        RouteList.backdrop,
        arguments: BackDropArguments(
          config: productConfig.toJson(),
          data: products ?? [],
          countdownDuration: countdownDuration,
        ),
      );
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  /// parse product from json
  static List<Product> parseProductList(response, config) {
    var list = <Product>[];
    if (response != null) {
      for (var item in response) {
        if (kAdvanceConfig['hideOutOfStock'] ?? false) {
          /// hideOutOfStock product
          if (((item['manage_stock'] ?? false) &&
                  !(item['in_stock'] ?? true)) ||
              (item['stock_quantity'] is int && item['stock_quantity'] == 0)) {
            continue;
          }
        }

        var product = Product.fromJson(item);

        if (config['category'] != null && "${config["category"]}".isNotEmpty) {
          product.categoryId = config['category'].toString();
        }
        if (item['store'] != null) {
          if (item['store']['errors'] != null) {
            list.add(product);
            continue;
          }
          product = Services().widget.updateProductObject(product, item);
        }
        list.add(product);
      }
    }
    return list;
  }
}
