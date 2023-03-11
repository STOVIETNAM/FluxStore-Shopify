import 'dart:async';
import 'dart:convert' as convert;

import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../common/config.dart' show kAdvanceConfig;
import '../../../common/constants.dart';
import '../../../models/entities/index.dart';
import '../../../models/index.dart'
    show
        Address,
        CartModel,
        Category,
        CheckoutCart,
        CreditCardModel,
        Order,
        PaymentMethod,
        PaymentSettings,
        PaymentSettingsModel,
        Product,
        ProductModel,
        ProductVariation,
        Review,
        ShippingMethod,
        User;
import '../../../models/vendor/store_model.dart' as store_model;
import '../../../services/base_services.dart';
import 'shopify_query.dart';
import 'shopify_storage.dart';

class ShopifyService extends BaseServices {
  ShopifyService({
    required String domain,
    String? blogDomain,
    required String accessToken,
  }) : super(domain: domain, blogDomain: blogDomain) {
    client = getClient(accessToken);
  }

  late GraphQLClient client;

  ShopifyStorage shopifyStorage = ShopifyStorage();

  GraphQLClient getClient(String accessToken) {
    final httpLink = HttpLink('$domain/api/graphql');
    final authLink = AuthLink(
      headerKey: 'X-Shopify-Storefront-Access-Token',
      getToken: () async => accessToken,
    );
    return GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  // Future<void> getCookie() async {
  //   final storage = injector<LocalStorage>();
  //   try {
  //     final json = storage.getItem(LocalStorageKey.shopifyCookie);
  //     if (json != null) {
  //       cookie = json;
  //     } else {
  //       cookie = 'OCSESSID=' +
  //           randomNumeric(30) +
  //           '; PHPSESSID=' +
  //           randomNumeric(30);
  //       await storage.setItem(LocalStorageKey.shopifyCookie, cookie);
  //     }
  //     printLog('Cookie storage: $cookie');
  //   } catch (err) {
  //     printLog(err);
  //   }
  // }

  Future<List<Category>> getCategoriesByCursor(
      {List<Category>? categories, String? cursor}) async {
    try {
      const nRepositories = 50;
      var variables = <String, dynamic>{'nRepositories': nRepositories};
      if (cursor != null) {
        variables['cursor'] = cursor;
      }
      final options = QueryOptions(
        document: gql(ShopifyQuery.readCollections),
        variables: variables,
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = categories ?? <Category>[];

      for (var item in result.data!['shop']['collections']['edges']) {
        var category = item['node'];
        list.add(Category.fromJsonShopify(category));
      }
      if (result.data?['shop']?['collections']?['pageInfo']?['hasNextPage'] ??
          false) {
        var lastCategory = result.data!['shop']['collections']['edges'].last;
        String? _cursor = lastCategory['cursor'];
        if (_cursor != null) {
          printLog('::::getCategories shopify by cursor $_cursor');
          return await getCategoriesByCursor(categories: list, cursor: _cursor);
        }
      }
      return list;
    } catch (e) {
      return categories ?? [];
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      printLog('::::request category');
      var categories = await getCategoriesByCursor();
      return categories;
    } catch (e) {
      printLog('::::getCategories shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({cursor, userId}) async {
    try {
      printLog('::::request products');

      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProducts),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'cursor': cursor
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Product>[];

      for (var item in result.data!['shop']['products']['edges']) {
        list.add(item['node']);
      }

      printLog(list);

      return list;
    } catch (e) {
      printLog('::::getProducts shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Product>?> fetchProductsLayout(
      {required config,
      lang,
      ProductModel? productModel,
      userId,
      bool refreshCache = false}) async {
    try {
      var list = <Product>[];
      if (config['layout'] == 'imageBanner' ||
          config['layout'] == 'circleCategory') {
        return list;
      }

      return await fetchProductsByCategory(
          categoryId: config['category'].toString(),
          productModel: productModel,
          page: config.containsKey('page') ? config['page'] : 1,
          limit: config['limit']);
    } catch (e) {
      printLog('::::fetchProductsLayout shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  // get sort key to filter product
  String getProductSortKey(onSale, featured, orderBy) {
    if (onSale == true) return 'BEST_SELLING';

    if (featured == true) return 'PRICE';

    if (orderBy == 'date') return 'UPDATED_AT';

    return 'PRODUCT_TYPE';
  }

  @override
  Future<List<Product>?> fetchProductsByCategory(
      {categoryId,
      tagId,
      page = 1,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      attribute,
      attributeTerm,
      featured,
      onSale,
      ProductModel? productModel,
      listingLocation,
      userId,
      nextCursor,
      String? include,
      limit}) async {
    printLog(
        '::::request fetchProductsByCategory with category id $categoryId');
    printLog(
        '::::request fetchProductsByCategory with cursor ${shopifyStorage.cursor}');

    /// change category id
    if (page == 1) {
      shopifyStorage.cursor = '';
      shopifyStorage.categoryId = categoryId;
      shopifyStorage.hasNextPage = true;
    }

    printLog(
        'fetchProductsByCategory with shopifyStorage ${shopifyStorage.toJson()}');

    try {
      var list = <Product>[];

      if (!shopifyStorage.hasNextPage!) {
        return list;
      }

      var currentCursor = shopifyStorage.cursor;

      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProductByCollection),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'categoryId': categoryId,
          'pageSize': limit ?? 20,
//          'sortKey': sortKey,
          'cursor': currentCursor != '' ? currentCursor : null
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var node = result.data?['node'];

      // printLog('fetchProductsByCategory with new node $node');

      if (node != null) {
        var productResp = node['products'];
        var pageInfo = productResp['pageInfo'];
        var hasNextPage = pageInfo['hasNextPage'];
        var edges = productResp['edges'];

        printLog(
            'fetchProductsByCategory with products length ${edges.length}');

        if (edges.length != 0) {
          var lastItem = edges.last;
          var cursor = lastItem['cursor'];

          printLog('fetchProductsByCategory with new cursor $cursor');

          // set next cursor
          shopifyStorage.setShopifyStorage(cursor, categoryId, hasNextPage);
        }

        for (var item in result.data!['node']['products']['edges']) {
          var product = item['node'];
          product['categoryId'] = categoryId;

          /// Hide out of stock.
          if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
              product['availableForSale'] == false) {
            continue;
          }
          list.add(Product.fromShopify(product));
        }
      }

      return list;
    } catch (e) {
      printLog('::::fetchProductsByCategory shopify error $e');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId,
      {int page = 1, int perPage = 10}) async {
    var list = <Review>[];

    return list;
  }

  Future<Address?> updateShippingAddress(
      {Address? address, String? checkoutId}) async {
    try {
      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingAddress),
        variables: {'shippingAddress': address, 'checkoutId': checkoutId},
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      printLog('updateShippingAddress $result');

      return null;
    } catch (e) {
      printLog('::::updateShippingAddress shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    CartModel? cartModel,
    String? token,
    String? checkoutId,
    store_model.Store? store,
  }) async {
    try {
      var list = <ShippingMethod>[];
      var newAddress = cartModel!.address!.toShopifyJson()['address'];

      printLog('getShippingMethods with checkoutId $checkoutId');

      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingAddress),
        variables: {'shippingAddress': newAddress, 'checkoutId': checkoutId},
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw ('So sorry, We do not support shipping to your address.');
      }

      var checkout =
          result.data!['checkoutShippingAddressUpdateV2']['checkout'];
      var availableShippingRates = checkout['availableShippingRates'];

      if (availableShippingRates['ready']) {
        for (var item in availableShippingRates['shippingRates']) {
          list.add(ShippingMethod.fromShopifyJson(item));
        }
      }

      // update checkout
      CheckoutCart.fromJsonShopify(checkout);

      printLog('getShippingMethods $list');

      return list;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateShippingLine(
      String checkoutId, String shippingRateHandle) async {
    try {
      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingLine),
        variables: {
          'checkoutId': checkoutId,
          'shippingRateHandle': shippingRateHandle
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data!['checkoutShippingLineUpdate']['checkout'];

      return checkout;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
      ShippingMethod? shippingMethod,
      String? token}) async {
    try {
      var list = <PaymentMethod>[];

      list.add(PaymentMethod.fromJson({
        'id': '0',
        'title': 'Checkout Free',
        'description': '',
        'enabled': true,
      }));

      list.add(PaymentMethod.fromJson({
        'id': '1',
        'title': 'Checkout Credit card',
        'description': '',
        'enabled': true,
      }));

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Product>> searchProducts({
    name,
    categoryId = '',
    categoryName = '',
    tag = '',
    attribute = '',
    attributeId = '',
    page,
    lang,
    listingLocation,
    userId,
  }) async {
    try {
      printLog('::::request searchProducts');
      const pageSize = 25;
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProductByName),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'query': '$name $categoryName',
          if (page != null) 'cursor': page,
          'pageSize': pageSize
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Product>[];
      String? lastCursor;
      for (var item in result.data!['shop']['products']['edges']) {
        lastCursor = item['cursor'];

        /// Hide out of stock.
        if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
            item['node']?['availableForSale'] == false) {
          continue;
        }
        list.add(Product.fromShopify(item['node']));
      }

      printLog(list);

      return PagingResponse(data: list, cursor: lastCursor);
    } catch (e) {
      printLog('::::searchProducts shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      printLog('::::request createUser');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.createCustomer),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {
              'firstName': firstName,
              'lastName': lastName,
              'email': username,
              'password': password
            }
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final listError =
          List.from(result.data?['customerCreate']?['userErrors'] ?? []);
      if (listError.isNotEmpty) {
        final message = listError.map((e) => e['message']).join(', ');
        throw Exception('$message!');
      }

      printLog('createUser ${result.data}');

      var userInfo = result.data!['customerCreate']['customer'];
      final token =
          await createAccessToken(username: username, password: password);
      var user = User.fromShopifyJson(userInfo, token);

      return user;
    } catch (e) {
      printLog('::::createUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User?> getUserInfo(cookie) async {
    try {
      printLog('::::request getUserInfo');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.getCustomerInfo),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'accessToken': cookie
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var user = User.fromShopifyJson(result.data?['customer'] ?? {}, cookie);
      if (user.cookie == null) return null;
      return user;
    } catch (e) {
      printLog('::::getUserInfo shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String? token) async {
    try {
      printLog('::::request updateUser');

      const nRepositories = 50;
      json.removeWhere((key, value) => key == 'deviceToken');
      final options = QueryOptions(document: gql(ShopifyQuery.customerUpdate),
          // fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'customerAccessToken': token,
            'customer': json,
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      // When update password, full user info will get null
      final user = await getUserInfo(token);
      if (user == null) {
        json['cookie'] = token;
        return json;
      }
      return user.toJson();
    } catch (e) {
      printLog('::::updateUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<String?> createAccessToken({username, password}) async {
    try {
      printLog('::::request createAccessToken');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.createCustomerToken),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {'email': username, 'password': password}
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json =
          result.data!['customerAccessTokenCreate']['customerAccessToken'];
      printLog("json['accessToken'] ${json['accessToken']}");

      return json['accessToken'];
    } catch (e) {
      printLog('::::createAccessToken shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User?> login({username, password}) async {
    try {
      printLog('::::request login');

      var accessToken =
          await createAccessToken(username: username, password: password);
      var userInfo = await getUserInfo(accessToken);

      printLog('login $userInfo');

      return userInfo;
    } catch (e) {
      printLog('::::login shopify error');
      printLog(e.toString());
      throw Exception(
          'Please check your username or password and try again. If the problem persists, please contact support!');
    }
  }

  @override
  Future<Product> getProduct(id, {lang, cursor}) async {
    /// Private id is id has been encrypted by Shopify, which is get via api
    final isPrivateId = int.tryParse(id) == null;
    if (isPrivateId) {
      return getProductByPrivateId(id);
    }
    printLog('::::request getProduct $id');

    /// Normal id is id the user can see on the admin site, which is not encrypt
    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductById),
      variables: <String, dynamic>{'nRepositories': nRepositories, 'id': id},
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }
    List? listData = result.data?['products']?['edges'];
    if (listData != null && listData.isNotEmpty) {
      final productData = listData.first['node'];
      return Product.fromShopify(productData);
    }
    return Product();
  }

  Future<Product> getProductByPrivateId(id) async {
    printLog('::::request getProductByPrivateId $id');

    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductByPrivateId),
      variables: <String, dynamic>{'nRepositories': nRepositories, 'id': id},
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }
    return Product.fromShopify(result.data!['node']);
  }

  Future<Map<String, dynamic>?> checkoutLinkUser(
      String? checkoutId, String? token) async {
    final options = MutationOptions(
      document: gql(ShopifyQuery.checkoutLinkUser),
      variables: {
        'checkoutId': checkoutId,
        'customerAccessToken': token,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    var checkout = result.data!['checkoutCustomerAssociateV2']['checkout'];

    return checkout;
  }

  Future addItemsToCart(CartModel cartModel) async {
    final cookie = cartModel.user?.cookie;
    try {
      if (cookie != null) {
        var lineItems = [];

        printLog('addItemsToCart productsInCart ${cartModel.productsInCart}');
        printLog(
            'addItemsToCart productVariationInCart ${cartModel.productVariationInCart}');

        for (var productId in cartModel.productVariationInCart.keys) {
          var variant = cartModel.productVariationInCart[productId]!;
          var productCart = cartModel.productsInCart[productId];

          printLog('addItemsToCart $variant');

          lineItems.add({'variantId': variant.id, 'quantity': productCart});
        }

        printLog('addItemsToCart lineItems $lineItems');
        final options = MutationOptions(
          document: gql(ShopifyQuery.createCheckout),
          variables: {
            'input': {
              'lineItems': lineItems,
            },
            if (cartModel.address != null) ...{
              'email': cartModel.address!.email,
            }
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        final checkout = result.data!['checkoutCreate']['checkout'];

        printLog('addItemsToCart checkout $checkout');

        // start link checkout with user
        // final cookie = userModel.user?.cookie;
        // if (cookie != null) {
        //   final newCheckout = await (checkoutLinkUser(checkout['id'], cookie));
        //
        //   return CheckoutCart.fromJsonShopify(newCheckout ?? {});
        // }
        return CheckoutCart.fromJsonShopify(checkout);
      } else {
        throw ('You need to login to checkout');
      }
    } catch (e) {
      printLog('::::addItemsToCart shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateItemsToCart(CartModel cartModel, String? cookie) async {
    try {
      if (cookie != null) {
        var lineItems = [];
        var checkoutId = cartModel.checkout!.id;

        printLog(
            'updateItemsToCart productsInCart ${cartModel.productsInCart}');
        printLog(
            'updateItemsToCart productVariationInCart ${cartModel.productVariationInCart}');

        for (var productId in cartModel.productVariationInCart.keys) {
          var variant = cartModel.productVariationInCart[productId]!;
          var productCart = cartModel.productsInCart[productId];

          printLog('updateItemsToCart $variant');

          lineItems.add({'variantId': variant.id, 'quantity': productCart});
        }

        printLog('updateItemsToCart lineItems $lineItems');

        final options = MutationOptions(
          document: gql(ShopifyQuery.updateCheckout),
          variables: <String, dynamic>{
            'lineItems': lineItems,
            'checkoutId': checkoutId
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        var checkout = result.data!['checkoutLineItemsReplace']['checkout'];

        return CheckoutCart.fromJsonShopify(checkout);
      } else {
        throw Exception('You need to login to checkout');
      }
    } catch (err) {
      printLog('::::updateItemsToCart shopify error');
      printLog(err.toString());
      rethrow;
    }
  }

  Future<CheckoutCart> applyCoupon(
    CartModel cartModel,
    String discountCode,
  ) async {
    try {
      var lineItems = [];

      printLog('applyCoupon ${cartModel.productsInCart}');

      printLog('applyCoupon $lineItems');

      final options = MutationOptions(
        document: gql(ShopifyQuery.applyCoupon),
        variables: {
          'discountCode': discountCode,
          'checkoutId': cartModel.checkout!.id
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data!['checkoutDiscountCodeApplyV2']['checkout'];

      return CheckoutCart.fromJsonShopify(checkout);
    } catch (e) {
      printLog('::::applyCoupon shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<CheckoutCart> removeCoupon(String? checkoutId) async {
    try {
      final options = MutationOptions(
        document: gql(ShopifyQuery.removeCoupon),
        variables: {
          'checkoutId': checkoutId,
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data!['checkoutDiscountCodeRemove']['checkout'];

      return CheckoutCart.fromJsonShopify(checkout);
    } catch (e) {
      printLog('::::removeCoupon shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateCheckout({
    String? checkoutId,
    String? note,
    DateTime? deliveryDate,
  }) async {
    var deliveryInfo = [];
    if (deliveryDate != null) {
      final dateFormat = DateFormat(DateTimeFormatConstants.ddMMMMyyyy);
      final dayFormat = DateFormat(DateTimeFormatConstants.weekday);
      final timeFormat = DateFormat(DateTimeFormatConstants.timeHHmmFormatEN);
      deliveryInfo = [
        {
          'key': 'Delivery Date',
          'value': dateFormat.format(deliveryDate),
        },
        {
          'key': 'Delivery Day',
          'value': dayFormat.format(deliveryDate),
        },
        {
          'key': 'Delivery Time',
          'value': timeFormat.format(deliveryDate),
        },
        // {
        //   'key': 'Date create',
        //   'value': timeFormat.format(DateTime.now()),
        // },
      ];
    }
    final options = MutationOptions(
      document: gql(ShopifyQuery.updateCheckoutAttribute),
      variables: <String, dynamic>{
        'checkoutId': checkoutId,
        'input': {
          'note': note,
          if (deliveryDate != null) 'customAttributes': deliveryInfo,
        },
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }
  }

  // Shopify does not support social login
  // @override
  // Future<User> loginGoogle({String? token}) async {
  //   try {
  //     var response = await httpPost(
  //         '$domain/index.php?route=extension/mstore/account/socialLogin'
  //             .toUri()!,
  //         body: convert.jsonEncode({'token': token, 'type': 'google'}),
  //         headers: {'content-type': 'application/json', 'cookie': cookie!});
  //     final body = convert.jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       return User.fromOpencartJson(body['data'], '');
  //     } else {
  //       List? error = body['error'];
  //       if (error != null && error.isNotEmpty) {
  //         throw Exception(error[0]);
  //       } else {
  //         throw Exception('Login fail');
  //       }
  //     }
  //   } catch (err) {
  //     rethrow;
  //   }
  // }

  // payment settings from shop
  @override
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      printLog('::::request paymentSettings');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.getPaymentSettings),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json = result.data!['shop']['paymentSettings'];

      printLog('paymentSettings $json');

      return PaymentSettings.fromShopifyJson(json);
    } catch (e) {
      printLog('::::paymentSettings shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<PaymentSettings> addCreditCard(
      PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) async {
    try {
      var response = await httpPost(
          paymentSettingsModel.getCardVaultUrl()!.toUri()!,
          body: convert.jsonEncode(creditCardModel),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return PaymentSettings.fromVaultIdShopifyJson(body['data']);
      } else {
        List? error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future checkoutWithCreditCard(String? vaultId, CartModel cartModel,
      Address address, PaymentSettingsModel paymentSettingsModel) async {
    try {
      try {
        var uuid = const Uuid();
        var paymentAmount = {
          'amount': cartModel.getTotal(),
          'currencyCode': cartModel.getCurrency()
        };

        final options = MutationOptions(
          document: gql(ShopifyQuery.checkoutWithCreditCard),
          variables: {
            'checkoutId': cartModel.checkout!.id,
            'payment': {
              'paymentAmount': paymentAmount,
              'idempotencyKey': uuid.v1(),
              'billingAddress': address.toShopifyJson()['address'],
              'vaultId': vaultId,
              'test': true
            }
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        var checkout =
            result.data!['checkoutCompleteWithCreditCardV2']['checkout'];

        return CheckoutCart.fromJsonShopify(checkout);
      } catch (e) {
        printLog('::::applyCoupon shopify error');
        printLog(e.toString());
        rethrow;
      }
    } catch (e) {
      printLog('::::checkoutWithCreditCard shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>?> getProductVariations(Product product,
      {String? lang = 'en'}) async {
    try {
      return product.variations;
    } catch (e) {
      printLog('::::getProductVariations shopify error');
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Blog>> getBlogs(dynamic cursor) async {
    try {
      printLog('::::request blogs');

      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getArticle),
        variables: {
          'nRepositories': nRepositories,
          'pageSize': 12,
          if (cursor != null && cursor is! num) 'cursor': cursor,
        },
      );
      final response = await client.query(options);

      if (response.hasException) {
        printLog(response.exception.toString());
      }

      final data = <Blog>[];
      String? lastCursor;
      for (var item in response.data!['shop']['articles']['edges']) {
        final blog = item['node'];
        lastCursor = item['cursor'];
        data.add(Blog.fromJson(blog));
      }

      return PagingResponse(
        data: data,
        cursor: lastCursor,
      );

      // printLog(list);
    } catch (e) {
      printLog('::::fetchBlogLayout shopify error');
      printLog(e.toString());
      return const PagingResponse();
    }
  }

  @override
  Future<PagingResponse<Order>> getMyOrders(
      {User? user, dynamic cursor}) async {
    try {
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getOrder),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'customerAccessToken': user!.cookie,
          if (cursor != null) 'cursor': cursor,
          'pageSize': 50
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Order>[];
      String? lastCursor;

      for (var item in result.data!['customer']['orders']['edges']) {
        lastCursor = item['cursor'];
        var order = item['node'];
        list.add(Order.fromJson(order));
      }
      return PagingResponse(
        cursor: lastCursor,
        data: list,
      );
    } catch (e) {
      printLog('::::getMyOrders shopify error');
      printLog(e.toString());
      return const PagingResponse();
    }
  }

  @override
  Future<String> submitForgotPassword({
    String? forgotPwLink,
    Map<String, dynamic>? data,
  }) async {
    final options = MutationOptions(
      document: gql(ShopifyQuery.resetPassword),
      variables: {
        'email': data!['email'],
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    final List? errors = result.data!['customerRecover']['customerUserErrors'];
    const errorCode = 'UNIDENTIFIED_CUSTOMER';
    if (errors?.isNotEmpty ?? false) {
      if (errors!.any((element) => element['code'] == errorCode)) {
        throw Exception(errorCode);
      }
    }

    return '';
  }

  @override
  Future<Product?> getProductByPermalink(String productPermalink) async {
    final handle =
        productPermalink.substring(productPermalink.lastIndexOf('/') + 1);
    printLog('::::request getProduct $productPermalink');

    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductByHandle),
      variables: <String, dynamic>{
        'nRepositories': nRepositories,
        'handle': handle
      },
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }

    final productData = result.data?['productByHandle'];
    return Product.fromShopify(productData);
  }

  Future<Order?> getLatestOrder({required String cookie}) async {
    try {
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getOrder),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'customerAccessToken': cookie,
          'pageSize': 1
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      for (var item in result.data!['customer']['orders']['edges']) {
        var order = item['node'];
        return Order.fromJson(order);
      }
    } catch (e) {
      printLog('::::getLatestOrder shopify error');
      printLog(e.toString());
      return null;
    }
    return null;
  }
}
