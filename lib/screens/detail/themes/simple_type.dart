// ignore_for_file: unused_shown_name

import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools/flash.dart';
import '../../../models/app_model.dart';
import '../../../models/index.dart'
    show CartModel, Product, ProductModel, ProductVariation, UserModel;
import '../../../modules/firebase/firebase_analytics_service.dart';
import '../../../routes/flux_navigate.dart';
import '../../../services/index.dart';
import '../../../widgets/general/tool_tip.dart';
import '../../../widgets/product/widgets/heart_button.dart';
import '../../chat/vendor_chat.dart';
import '../widgets/harold_videos.dart';
import '../widgets/index.dart';
import '../widgets/product_appbar_image_button.dart';
import '../widgets/product_gurantees.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_navigation_buttons.dart';

class SimpleLayout extends StatefulWidget {
  final Product product;
  final bool isLoading;

  const SimpleLayout({required this.product, this.isLoading = false});

  @override
  // ignore: no_logic_in_create_state
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  late Product product;
  final services = Services();
  int _quantity = 1;
  ProductVariation? _productVariation;
  List<ProductVariation>? variations;
  _SimpleLayoutState({required this.product});

  Map<String, String> mapAttribute = HashMap();
  var top = 0.0;
  final bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SimpleLayout oldWidget) {
    if (oldWidget.product.type != widget.product.type) {
      setState(() {
        product = widget.product;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Render product default: booking, group, variant, simple, booking
  Widget renderProductInfo() {
    var body;
    if (widget.isLoading == true) {
      body = kLoadingWidget(context);
    } else {
      switch (product.type) {
        case 'appointment':
          return Services().getBookingLayout(product: product);
        case 'booking':
          body = ListingBooking(product);
          break;
        case 'grouped':
          body = GroupedProduct(product);
          break;
        default:
          body = ProductVariant(
            product,
            onSelectProductVariation: (ProductVariation variation) {
              _productVariation = variation;
            },
            onSelectQuantity: (int quantity) {
              setState(() {
                _quantity = quantity;
              });
            },
            onUpdateProductVariations: (List<ProductVariation> variation) {
              variations = variation;
            },
          );
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthHeight = size.height;

    final userModel = Provider.of<UserModel>(context, listen: false);
    final appModel = Provider.of<AppModel>(context, listen: false);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail.safeArea,
        child: ChangeNotifierProvider(
          create: (_) => ProductModel(),
          child: Stack(
            children: <Widget>[
              OverlayTooltipScaffold(
                controller: appModel.productDetailToolTipController,
                tooltipAnimationCurve: Curves.linear,
                tooltipAnimationDuration: const Duration(milliseconds: 1000),
                builder: (context) => Scaffold(
                  floatingActionButton: (!Config().isVendorType() ||
                          !kConfigChat['EnableSmartChat'])
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: VendorChat(
                            user: userModel.user,
                            store: product.store,
                          ),
                        ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  body: CustomScrollView(
                    controller: userModel.scrollController,
                    slivers: <Widget>[
                      SliverAppBar(
                        systemOverlayStyle: SystemUiOverlayStyle.light,
                        backgroundColor: Theme.of(context).backgroundColor,
                        elevation: 1.0,
                        expandedHeight:
                            kIsWeb ? 0 : widthHeight * kProductDetail.height,
                        pinned: true,
                        floating: true,
                        centerTitle: true,
                        leading: Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: kGrey600,
                              ),
                              onPressed: () {
                                context
                                    .read<ProductModel>()
                                    .clearProductVariations();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          if (widget.isLoading != true)
                            HeartButton(
                              product: product,
                              size: 18.0,
                              color: Colors.black,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.5),
                              child: IconButton(
                                icon: const Icon(
                                  CupertinoIcons.cart,
                                  size: 18.0,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  FluxNavigate.pushNamed(
                                    RouteList.cart,
                                  );
                                },
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(12),
                          //   child: CircleAvatar(
                          //     backgroundColor: Colors.white.withOpacity(0.3),
                          //     child: IconButton(
                          //       icon: const Icon(Icons.more_vert, size: 19),
                          //       color: kGrey600,
                          //       onPressed: () => ProductDetailScreen.showMenu(
                          //           context, widget.product,
                          //           isLoading: widget.isLoading),
                          //     ),
                          //   ),
                          // ),
                        ],
                        flexibleSpace: kIsWeb
                            ? const SizedBox()
                            : ProductImageSlider(
                                product: product,
                              ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          <Widget>[
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration:
                                  BoxDecoration(color: Colors.grey[100]),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              OverlayTooltipItem(
                                                displayIndex: 0,
                                                tooltipVerticalPosition:
                                                    TooltipVerticalPosition
                                                        .BOTTOM,
                                                tooltip: (controller) =>
                                                    Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: MTooltip(
                                                      title: 'Videos',
                                                      subTitle:
                                                          'Checkout product videos before making a purchase',
                                                      controller: controller),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child:
                                                      ProductAppBarImageButton(
                                                    // height:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         .11,
                                                    icon:
                                                        'assets/images/video_icon.png',
                                                    onTap: () {
                                                      FirebaseAnalyticsService
                                                          .videoProduct({
                                                        'id': product.id,
                                                        'itemName':
                                                            product.name,
                                                        });
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  // ProductVideos()
                                                                  HaroldProductVideos(
                                                                    product:
                                                                        product,
                                                                  )));
                                                    },
                                                    title: 'Video',
                                                  ),
                                                ),
                                              ),
                                              OverlayTooltipItem(
                                                displayIndex: 1,
                                                tooltipVerticalPosition:
                                                    TooltipVerticalPosition
                                                        .BOTTOM,
                                                tooltip: (controller) =>
                                                    Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: MTooltip(
                                                      nextOnTap: () async {
                                                        controller.dismiss();

                                                        if (userModel
                                                            .scrollController
                                                            .hasClients) {
                                                          await userModel.scrollController.animateTo(
                                                              userModel
                                                                  .scrollController
                                                                  .position
                                                                  .maxScrollExtent,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000),
                                                              curve: Curves
                                                                  .fastOutSlowIn);
                                                        }
                                                        controller.next();
                                                      },
                                                      title: 'Get In Touch',
                                                      subTitle:
                                                          'Get in touch with our lighting expert to know more',
                                                      controller: controller),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          // left: 15,
                                                          // right: 15,`
                                                          top: 5,
                                                          bottom: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child:
                                                      ProductAppBarImageButton(
                                                    // height:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .width *
                                                    //         .11,
                                                    icon:
                                                        'assets/images/connect_with_us_icon.png',
                                                    onTap: () {
                                                      FirebaseAnalyticsService
                                                          .chatWithUs({
                                                        'platform': 'whatsapp',
                                                      });
                                                      launch(
                                                          'https://api.whatsapp.com/send/?phone=%2B919971772611&text=%20I%20am%20interested%20in%20your%20products');
                                                    },
                                                    title: 'Connect With Us',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: ProductAppBarImageButton(
                                                  // height: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     .11,
                                                  icon:
                                                      'assets/images/share_icon.png',
                                                  onTap: () {
                                                    FirebaseAnalyticsService
                                                        .shareProduct({
                                                      'id': product.id,
                                                      'itemName':
                                                          product.name ?? '',
                                                    });
                                                    Services()
                                                        .firebase
                                                        .shareDynamicLinkProduct(
                                                          context: context,
                                                          itemUrl:
                                                              product.permalink,
                                                        );
                                                  },
                                                  title: 'Share',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: ProductAppBarImageButton(
                                                  // height: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width *
                                                  //     .11,
                                                  icon:
                                                      'assets/images/ar_icon.png',
                                                  onTap: () {
                                                    FlashHelper.toast(
                                                        'AR feature coming soon');
                                                    // FlashHelper.actionBar(
                                                    //     context,
                                                    //     title: '',
                                                    //     presistent: true,
                                                    //     duration:
                                                    //         const Duration(
                                                    //             seconds: 3),
                                                    //     message:
                                                    //         'AR feature coming soon',
                                                    //     onPrimaryActionTap:
                                                    //         ((controller) {}),
                                                    //     primaryAction:
                                                    //         const SizedBox());
                                                  },
                                                  title: 'View In Your Room',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // SizedBox(
                                        //     width: MediaQuery.of(context)
                                        //             .size
                                        //             .width *
                                        //         .06),
                                        // Column(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.center,
                                        //   children: [
                                        //     // const SizedBox(
                                        //     //   height: 16,
                                        //     // ),
                                        //     SmoothStarRating(
                                        //         allowHalfRating: true,
                                        //         starCount: 5,
                                        //         size: 18,
                                        //         rating: 4.3,
                                        //         spacing: 0.0),
                                        //     const SizedBox(
                                        //       height: 8,
                                        //     ),
                                        //     RichText(
                                        //         text: TextSpan(
                                        //       text: 'Overall rating',
                                        //       children: const [
                                        //         TextSpan(
                                        //             text: ' 4.3',
                                        //             style: TextStyle(
                                        //                 color: Colors.black,
                                        //                 fontWeight:
                                        //                     FontWeight.bold)),
                                        //       ],
                                        //       style: Theme.of(context)
                                        //           .textTheme
                                        //           .caption!
                                        //           .copyWith(
                                        //               color: Colors.grey[700]),
                                        //     )),
                                        //   ],
                                        // )
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .04),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 8),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            child: const Text(
                                              'COMING SOON',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            if (kIsWeb)
                              ProductGallery(
                                product: widget.product,
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 4.0,
                                left: 15,
                                right: 15,
                              ),
                              child: product.type == 'grouped'
                                  ? const SizedBox()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ProductTitle(product),
                                        // TextButton(
                                        //     onPressed: () {
                                        //       Navigator.of(context).pushNamed(
                                        //           RouteList.arProductDetail,
                                        //           arguments: ProductARArguments(
                                        //               source:
                                        //                   'https://cdn.shopify.com/s/files/1/0047/8022/8698/files/Black_Mamba_Chandelier_1.glb',
                                        //               title: product.name!));
                                        //     },
                                        //     child: Text(S.of(context).viewInAR,
                                        //         style: Theme.of(context)
                                        //             .textTheme
                                        //             .button
                                        //             ?.copyWith(
                                        //                 fontSize: 15,
                                        //                 fontWeight:
                                        //                     FontWeight.w700)))
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      if (kEnableShoppingCart) renderProductInfo(),
                      if (!kEnableShoppingCart &&
                          product.shortDescription != null &&
                          product.shortDescription!.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: ProductShortDescription(product),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            // horizontal: 15.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: Column(
                                  children: [
                                    Services().widget.renderVendorInfo(product),
                                    const ProductGuarantees(),
                                    ProductDescription(product),
                                    if (kProductDetail.showProductCategories)
                                      ProductDetailCategories(product),
                                    ProductNavigationButtons(
                                      product: product,
                                    ),
                                    if (kProductDetail.showProductTags)
                                      ProductTag(product),
                                    Services()
                                        .widget
                                        .productReviewWidget(product.id ?? ''),
                                  ],
                                ),
                              ),
                              RelatedProduct(product),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(children: <Widget>[
                  // kEnableShoppingCart
                  //     ? Align(
                  //         alignment: Alignment.bottomRight,
                  //         child: ExpandingBottomSheet(
                  //           hideController: _hideController,
                  //           onToggle: (bool isOpen) {
                  //             setState(() {
                  //               _isSheetOpen = isOpen;
                  //             });
                  //           },
                  //         ))
                  //     : Container(),
                  !_isSheetOpen
                      ? Material(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Column(
                                  children: services.widget.getBuyButtonWidget(
                                      context,
                                      _productVariation,
                                      product,
                                      mapAttribute,
                                      getMaxQuantity(),
                                      _quantity,
                                      addToCart, (val) {
                                setState(() {
                                  _quantity = val;
                                });
                              }, variations, withQuantity: false))))
                      : Container()
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  int getMaxQuantity() {
    var limitSelectQuantity = kCartDetail['maxAllowQuantity'] ?? 100;

    /// Skip check stock quantity for backorder products.
    if (product.backordersAllowed) {
      return limitSelectQuantity;
    }

    if (_productVariation != null) {
      if (_productVariation!.stockQuantity != null) {
        limitSelectQuantity = math.min<int>(
            _productVariation!.stockQuantity!, kCartDetail['maxAllowQuantity']);
      }
    } else if (product.stockQuantity != null) {
      limitSelectQuantity = math.min<int>(
          product.stockQuantity!, kCartDetail['maxAllowQuantity']);
    }
    return limitSelectQuantity;
  }

  /// Add to Cart & Buy Now function
  void addToCart([bool buyNow = false, bool inStock = false]) {
    services.widget.addToCart(context, product, _quantity, _productVariation,
        mapAttribute, buyNow, inStock);
  }
}
