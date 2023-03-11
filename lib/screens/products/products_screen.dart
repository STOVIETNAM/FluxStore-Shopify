// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:harold/modules/firebase/firebase_analytics_service.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/index.dart'
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttributeModel,
        Product,
        ProductModel,
        UserModel;
import '../../models/product_wish_list_model.dart';
import '../../modules/dynamic_layout/helper/countdown_timer.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../routes/flux_navigate.dart';
import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/product/product_list.dart';
import 'products_backdrop.dart';

class ProductsScreen extends StatefulWidget {
  final List<Product>? products;
  final ProductConfig? config;
  final Duration countdownDuration;
  final bool showCategoryBar;
  final String? listingLocation;

  const ProductsScreen(
      {this.products,
      this.countdownDuration = Duration.zero,
      this.listingLocation,
      this.showCategoryBar = true,
      this.config});

  @override
  State<StatefulWidget> createState() {
    return ProductsScreenState();
  }
}

class ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ProductConfig get productConfig => widget.config ?? ProductConfig.empty();

  String? newTagId;
  String? newCategoryId;
  String? mainCatId;
  String? newListingLocationId;
  double? minPrice;
  double? maxPrice;
  String? orderBy;
  String? orDer;
  String? attribute;

  bool? featured;
  bool? onSale;

  bool isFiltering = false;
  List<Product>? products = [];
  String? errMsg;
  int _page = 1;

  late String _currentTitle;
  String _currentOrder = 'date';
  List? include;

  @override
  void initState() {
    super.initState();
    newCategoryId = productConfig.category ?? '-1';
    mainCatId = newCategoryId;
    newTagId = productConfig.tag;
    onSale = productConfig.onSale;
    featured = productConfig.featured;
    orderBy = productConfig.orderby;
    newListingLocationId = widget.listingLocation;
    _currentOrder = (onSale ?? false) ? 'on_sale' : 'date';
    include = productConfig.include;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    /// only request to server if there is empty config params
    /// If there is config, load the products one
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onRefresh(false);
    });
  }

  void onFilter({
    dynamic minPrice,
    dynamic maxPrice,
    dynamic categoryId,
    String? categoryName,
    String? tagId,
    dynamic attribute,
    dynamic currentSelectedTerms,
    dynamic listingLocationId,
  }) {
    _controller.forward();

    final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    newCategoryId = categoryId;

    newTagId = tagId;
    newListingLocationId = listingLocationId;
    if (minPrice == maxPrice && minPrice == 0) {
      this.minPrice = null;
      this.maxPrice = null;
    } else {
      this.minPrice = minPrice;
      this.maxPrice = maxPrice;
    }

    if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    var terms = '';

    if (currentSelectedTerms != null) {
      for (var i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }

    productModel.setProductsList([]);
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    productModel.getProductsList(
      categoryId: categoryId == -1 ? null : categoryId,
      minPrice: this.minPrice,
      maxPrice: this.maxPrice,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      orderBy: orderBy,
      order: orDer,
      featured: featured,
      onSale: onSale,
      tagId: tagId,
      attribute: attribute,
      attributeTerm: terms.isEmpty ? null : terms,
      userId: _userId,
      listingLocation: newListingLocationId,
      include: include,
    );

    /// Set title
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    final selectedCat = categories!
        .singleWhere((element) => element.id == categoryId.toString());
    productModel.categoryName = selectedCat.name;
    _currentTitle = selectedCat.name!;
    setState(() {});
  }

  void onSort(String order) {
    _currentOrder = order;
    switch (order) {
      case 'featured':
        featured = true;
        onSale = null;
        break;
      case 'on_sale':
        featured = null;
        onSale = true;
        break;
      case 'price':
        featured = null;
        onSale = null;
        orderBy = 'price';
        break;
      case 'date':
      default:
        featured = null;
        onSale = null;
        orderBy = 'date';
        break;
    }

    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    var terms = '';
    for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;

    Provider.of<ProductModel>(context, listen: false).getProductsList(
      categoryId: newCategoryId == '-1' ? null : newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      page: 1,
      orderBy: orderBy,
      order: 'desc',
      featured: featured,
      onSale: onSale,
      attribute: attribute,
      attributeTerm: terms,
      tagId: newTagId,
      userId: _userId,
      listingLocation: newListingLocationId,
      include: include,
    );
  }

  Future<void> onRefresh([loadingConfig = true]) async {
    _page = 1;

    /// Important:
    /// The config is determine to load category/tag from config
    /// Or load from Caching ProductsLayout
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    var terms = '';
    for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;

    await Provider.of<ProductModel>(context, listen: false).getProductsList(
      categoryId: newCategoryId == '-1' ? null : newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      onSale: onSale,
      featured: featured,
      page: 1,
      orderBy: orderBy,
      order: orDer,
      attribute: attribute,
      attributeTerm: terms,
      tagId: newTagId,
      listingLocation: newListingLocationId,
      userId: _userId,
      include: include,
    );
  }

  Widget? renderCategoryAppbar() {
    final category = Provider.of<CategoryModel>(context);
    var parentCategory = newCategoryId;
    if (category.categories != null && category.categories!.isNotEmpty) {
      parentCategory =
          getParentCategories(category.categories, parentCategory) ??
              parentCategory;
      final listSubCategory =
          getSubCategories(category.categories, parentCategory)!;
      if (category.categories != null && category.categories!.isNotEmpty) {
        var mainCatIndex = category.categories
            ?.indexWhere((element) => element.id == mainCatId);
        var mainCat = category.categories![mainCatIndex!];
        var temp = category.categories![0];
        category.categories![mainCatIndex] = temp;
        category.categories![0] = mainCat;
      }

      //   if (listSubCategory.length < 2) return null;

      return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }

          if (value.categories != null) {
            var _renderListCategory = <Widget>[];
            // _renderListCategory.add(const SizedBox(width: 10));

            // _renderListCategory.add(
            //   _renderItemCategory(context,
            //       categoryId: parentCategory,
            //       categoryName: S.of(context).seeAll),
            // );

            _renderListCategory.addAll([
              for (var category in category.categories!

                  // getSubCategories(value.categories, parentCategory)!

                  )
                _renderItemCategory(
                  context,
                  categoryId: category.id,
                  categoryName: category.name!,
                )
            ]);

            return Container(
              color: Theme.of(context).backgroundColor,
              height: 50,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _renderListCategory,
                  ),
                ),
              ),
            );
          }

          return Container();
        }),
      );
    }
    return null;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  String? getParentCategories(categories, id) {
    for (var item in categories) {
      if (item.id == id) {
        return (item.parent == null || item.parent == '0') ? null : item.parent;
      }
    }
    return '0';
    // return categories.where((o) => ((o.id == id) ? o.parent : null));
  }

  Widget _renderItemCategory(BuildContext context,
      {String? categoryId, required String categoryName}) {
    return GestureDetector(
      onTap: () {
        FirebaseAnalyticsService.productCategoty({
          'id': categoryId,
          'categoryName': categoryName,
        });
        _page = 1;
        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
        include = null;

        Provider.of<ProductModel>(context, listen: false).getProductsList(
          categoryId: categoryId,
          page: _page,
          onSale: onSale,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          tagId: newTagId,
          userId: _userId,
          orderBy: orderBy,
          order: orDer,
          featured: featured,
          attribute: attribute,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );

        setState(() {
          newCategoryId = categoryId;
          onFilter(
              minPrice: minPrice,
              maxPrice: maxPrice,
              categoryId: newCategoryId,
              tagId: newTagId,
              listingLocationId: newListingLocationId);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color:
              newCategoryId == categoryId ? Colors.white38 : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          categoryName.toUpperCase(),
          style: Theme.of(context).textTheme.caption!.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ),
    );
  }

  void onLoadMore() async {
    _page = _page + 1;
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    var terms = '';
    for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;

    await Provider.of<ProductModel>(context, listen: false).getProductsList(
      categoryId: newCategoryId == '-1' ? null : newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      page: _page,
      orderBy: orderBy,
      order: orDer,
      featured: featured,
      onSale: onSale,
      attribute: attribute,
      attributeTerm: terms,
      tagId: newTagId,
      userId: _userId,
      listingLocation: newListingLocationId,
      include: include,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context, listen: true);
    _currentTitle =
        productConfig.name ?? product.categoryName ?? S.of(context).products;
    final layout =
        Provider.of<AppModel>(context, listen: false).productListLayout;

    final ratioProductImage =
        Provider.of<AppModel>(context, listen: false).ratioProductImage;

    final isListView = layout != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    ProductBackdrop backdrop({products, isFetching, errMsg, isEnd, width}) =>
        ProductBackdrop(
          backdrop: Backdrop(
            bgColor: productConfig.backgroundColor,
            selectSort: _currentOrder,
            showFilter: false,
            showSort: false,
            frontLayer: isListView
                ? ProductList(
                    products: products,
                    onRefresh: onRefresh,
                    onLoadMore: onLoadMore,
                    isFetching: isFetching,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: layout,
                    ratioProductImage: ratioProductImage,
                    width: width,
                  )
                : AsymmetricView(
                    products: products,
                    isFetching: isFetching,
                    isEnd: isEnd,
                    onLoadMore: onLoadMore,
                    width: width),
            backLayer: BackdropMenu(
              onFilter: onFilter,
              categoryId: newCategoryId,
              tagId: newTagId,
              listingLocationId: newListingLocationId,
            ),
            frontTitle: productConfig.showCountDown
                ? Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentTitle),
                          CountDownTimer(widget.countdownDuration)
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_currentTitle),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                CupertinoIcons.search,
                                size: 22,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                FluxNavigate.pushNamed(
                                  RouteList.search,
                                );
                              },
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.heart,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    FluxNavigate.pushNamed(
                                      RouteList.wishlist,
                                    );
                                  },
                                ),
                                Consumer<ProductWishListModel>(
                                    builder: (context, snapshot, _) {
                                  return snapshot.wishlistCount > 0
                                      ? Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              snapshot.wishlistCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Container();
                                })
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.cart,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    FluxNavigate.pushNamed(
                                      RouteList.cart,
                                    );
                                  },
                                ),
                                Consumer<CartModel>(
                                    builder: (context, snapshot, _) {
                                  return snapshot.totalCartQuantity > 0
                                      ? Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              snapshot.totalCartQuantity
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Container();
                                })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            backTitle: Text(S.of(context).filter),
            controller: _controller,
            onSort: onSort,
            appbarCategory:
                widget.showCategoryBar ? renderCategoryAppbar() : null,
          ),
          // expandingBottomSheet: (kEnableShoppingCart && !Config().isListingType)
          //     ? ExpandingBottomSheet(hideController: _controller)
          //     : null,
        );

    Widget buildMain = LayoutBuilder(
      builder: (context, constraint) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: ListenableProvider.value(
            value: product,
            child: Consumer<ProductModel>(
              builder: (context, value, child) {
                return backdrop(
                    products: value.productsList,
                    isFetching: value.isFetching,
                    errMsg: value.errMsg,
                    isEnd: value.isEnd,
                    width: constraint.maxWidth);
              },
            ),
          ),
        );
      },
    );
    return kIsWeb
        ? WillPopScope(
            onWillPop: () async {
              eventBus.fire(const EventOpenCustomDrawer());
              // LayoutWebCustom.changeStateMenu(true);
              Navigator.of(context).pop();
              return false;
            },
            child: buildMain,
          )
        : buildMain;
  }
}
