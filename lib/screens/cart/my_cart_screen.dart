import 'dart:async';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard, printLog;
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../menu/index.dart' show MainTabControlDelegate, tabController;
import '../../models/index.dart' show AppModel, CartModel, Product, UserModel;
import '../../modules/firebase/firebase_analytics_service.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/product/cart_item.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../checkout/checkout_screen.dart';
import '../common/header_widget.dart';
import 'widgets/empty_cart.dart';
import 'widgets/shopping_cart_sumary.dart';
import 'widgets/wishlist.dart';

class MyCart extends StatefulWidget {
  final bool? isModal;
  final bool? isBuyNow;

  const MyCart({
    this.isModal,
    this.isBuyNow = false,
  });

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String errMsg = '';

  CartModel get cartModel => Provider.of<CartModel>(context, listen: false);

  List<Widget> _createShoppingCartRows(CartModel model, BuildContext context) {
    return model.productsInCart.keys.map(
      (key) {
        var productId = Product.cleanProductID(key);
        var product = model.getProductById(productId);

        if (product != null) {
          return ShoppingCartRow(
            product: product,
            addonsOptions: model.productAddonsOptionsInCart[key],
            variation: model.getProductVariationById(key),
            quantity: model.productsInCart[key],
            options: model.productsMetaDataInCart[key],
            onRemove: () {
              model.removeItemFromCart(key);
            },
            onChangeQuantity: (val) {
              var message =
                  model.updateQuantity(product, key, val, context: context);
              if (message.isNotEmpty) {
                final snackBar = SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 1),
                );
                Future.delayed(
                  const Duration(milliseconds: 300),
                  // ignore: deprecated_member_use
                  () => ScaffoldMessenger.of(context).showSnackBar(snackBar),
                );
              }
            },
          );
        }
        return const SizedBox();
      },
    ).toList();
  }

  void _loginWithResult(BuildContext context) async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(
    //       fromCart: true,
    //     ),
    //     fullscreenDialog: kIsWeb,
    //   ),
    // );
    await FluxNavigate.pushNamed(
      RouteList.register,
      forceRootNavigator: true,
    ).then((value) {
      final user = Provider.of<UserModel>(context, listen: false).user;
      if (user != null && user.name != null) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).welcome + ' ${user.name} !');
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    printLog('[Cart] build');

    final localTheme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    var layoutType = Provider.of<AppModel>(context).productDetailLayout;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: Selector<CartModel, bool>(
        selector: (_, cartModel) => cartModel.calculatingDiscount,
        builder: (context, calculatingDiscount, child) {
          return FloatingActionButton.extended(
            onPressed: calculatingDiscount
                ? null
                : () {
                    if (kAdvanceConfig['AlwaysShowTabBar'] ?? false) {
                      MainTabControlDelegate.getInstance().changeTab('cart');
                      // return;
                    }
                    onCheckout(cartModel);
                  },
            isExtended: true,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            icon: const Icon(Icons.payment, size: 20),
            label: child!,
          );
        },
        child: Selector<CartModel, int>(
          selector: (_, carModel) => cartModel.totalCartQuantity,
          builder: (context, totalCartQuantity, child) {
            return totalCartQuantity > 0
                ? (isLoading
                    ? Text(S.of(context).loading.toUpperCase())
                    : Text(S.of(context).checkout.toUpperCase()))
                : Text(S.of(context).startShopping.toUpperCase());
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(title: S.of(context).myCart, isShowback: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                cacheExtent: MediaQuery.of(context).size.height * 2,
                physics: const BouncingScrollPhysics(),
                children: [
                  Consumer<CartModel>(
                    builder: (context, model, child) {
                      return AutoHideKeyboard(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 80.0, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (model.totalCartQuantity > 0)
                              //   Container(
                              //     // decoration: BoxDecoration(
                              //     //     color: Theme.of(context).primaryColorLight),
                              //     padding: const EdgeInsets.only(
                              //       right: 15.0,
                              //       top: 4.0,
                              //     ),
                              //     child: SizedBox(
                              //       width: screenSize.width,
                              //       child: SizedBox(
                              //         width: screenSize.width /
                              //             (2 /
                              //                 (screenSize.height /
                              //                     screenSize.width)),
                              //         child: Row(
                              //           children: [
                              //             const SizedBox(width: 25.0),
                              //             Text(
                              //               S.of(context).total.toUpperCase(),
                              //               style: localTheme
                              //                   .textTheme.subtitle1!
                              //                   .copyWith(
                              //                 fontWeight: FontWeight.w600,
                              //                 color: Theme.of(context)
                              //                     .primaryColor,
                              //                 fontSize: 14,
                              //               ),
                              //             ),
                              //             const SizedBox(width: 8.0),
                              //             Text(
                              //               '${model.totalCartQuantity} ${S.of(context).items}',
                              //               style: TextStyle(
                              //                   color: Theme.of(context)
                              //                       .primaryColor),
                              //             ),
                              //             Expanded(
                              //               child: Align(
                              //                 alignment: Tools.isRTL(context)
                              //                     ? Alignment.centerLeft
                              //                     : Alignment.centerRight,
                              //                 child: TextButton(
                              //                   onPressed: () {
                              //                     if (model.totalCartQuantity >
                              //                         0) {
                              //                       showDialog(
                              //                         context: context,
                              //                         useRootNavigator: false,
                              //                         builder: (BuildContext
                              //                             context) {
                              //                           return AlertDialog(
                              //                             content: Text(S
                              //                                 .of(context)
                              //                                 .confirmClearTheCart),
                              //                             actions: [
                              //                               TextButton(
                              //                                 onPressed: () {
                              //                                   Navigator.of(
                              //                                           context)
                              //                                       .pop();
                              //                                 },
                              //                                 child: Text(S
                              //                                     .of(context)
                              //                                     .keep),
                              //                               ),
                              //                               ElevatedButton(
                              //                                 onPressed: () {
                              //                                   Navigator.of(
                              //                                           context)
                              //                                       .pop();
                              //                                   model
                              //                                       .clearCart();
                              //                                 },
                              //                                 child: Text(
                              //                                   S
                              //                                       .of(context)
                              //                                       .clear,
                              //                                   style:
                              //                                       const TextStyle(
                              //                                     color: Colors
                              //                                         .white,
                              //                                   ),
                              //                                 ),
                              //                               ),
                              //                             ],
                              //                           );
                              //                         },
                              //                       );
                              //                     }
                              //                   },
                              //                   child: Text(
                              //                     S
                              //                         .of(context)
                              //                         .clearCart
                              //                         .toUpperCase(),
                              //                     style: const TextStyle(
                              //                       color: Colors.redAccent,
                              //                       fontSize: 12,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // if (model.totalCartQuantity > 0)
                              //   const Divider(
                              //     height: 1,
                              //     // indent: 25,
                              //   ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(height: 25.0),
                                  if (model.totalCartQuantity > 0)
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                offset: const Offset(0, 0),
                                                blurRadius: 10,
                                                color: Colors.black
                                                    .withOpacity(.09))
                                          ]),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10, top: 10),
                                            child: Column(
                                              children: _createShoppingCartRows(
                                                  model, context),
                                            ),
                                          ),
                                          GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              //  ExpandingBottomSheet.of(context)!
                                              tabController.animateTo(1);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 20),
                                              decoration: DottedDecoration(
                                                  dash: const [2],
                                                  linePosition:
                                                      LinePosition.top),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: const [
                                                  Text(
                                                    '+ Add more items',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color:
                                                            kColorBackCouponTitle12,
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 30),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '   Offers & Benefits',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: kColorBackCouponTitle5,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),

                                  Container(
                                    // height: 100,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              offset: const Offset(0, 0),
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(.09))
                                        ]),
                                    child: Column(
                                      children: [
                                        // const SizedBox(
                                        //   height: 70,
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                offerIcon,
                                                height: 20,
                                                width: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: const [
                                                        Text(
                                                          'SEAS10',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  kColorBackCouponTitle5,
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          'Save more 10% extra',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  kColorBackCouponTitle5,
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    const Text(
                                                      'Apply',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              kColorRedCoupon,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            unawaited(Navigator.of(context)
                                                .pushNamed(
                                                    RouteList.couponScreen));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 5),
                                            decoration: DottedDecoration(
                                              dash: const [2],
                                              linePosition: LinePosition.top,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'View More Coupons ',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          kColorBackCouponTitle7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                RotatedBox(
                                                  quarterTurns: 3,
                                                  child: Image.asset(
                                                    arrowDown,
                                                    height: 8,
                                                    width: 8,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, top: 5, bottom: 15),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Have any other code',
                                        hintStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: kColorBackCouponTitle3,
                                            fontFamily: 'Poppins'),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.solid,
                                              color: Colors.black),
                                        ),
                                        alignLabelWithHint: true,
                                        suffixIconConstraints:
                                            const BoxConstraints(maxHeight: 50),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.solid,
                                              color: kColorBackCouponTitle3),
                                        ),
                                        suffixIcon: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Text(
                                              S.of(context).apply.toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: kColorBackCouponTitle4,
                                                  fontFamily: 'Poppins'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const ShoppingCartSummary(),
                                  if (model.totalCartQuantity == 0) EmptyCart(),
                                  if (errMsg.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        errMsg,
                                        style:
                                            const TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  // const SizedBox(height: 4.0),
                                  // WishList()
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCheckout(CartModel model) {
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    var message;

    if (isLoading) return;

    if (kCartDetail['minAllowTotalCartValue'] != null) {
      if (kCartDetail['minAllowTotalCartValue'].toString().isNotEmpty) {
        var totalValue = model.getSubTotal() ?? 0;
        var minValue = PriceTools.getCurrencyFormatted(
            kCartDetail['minAllowTotalCartValue'], currencyRate,
            currency: currency);
        if (totalValue < kCartDetail['minAllowTotalCartValue'] &&
            model.totalCartQuantity > 0) {
          message = '${S.of(context).totalCartValue} $minValue';
        }
      }
    }

    if ((kVendorConfig['DisableMultiVendorCheckout'] ?? false) &&
        Config().isVendorType()) {
      if (!model.isDisableMultiVendorCheckoutValid(
          model.productsInCart, model.getProductById)) {
        message = S.of(context).youCanOnlyOrderSingleStore;
      }
    }

    if (message != null) {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        persistent: !Config().isBuilder,
        builder: (context, controller) {
          return SafeArea(
            child: Flash(
              borderRadius: BorderRadius.circular(3.0),
              backgroundColor: Theme.of(context).errorColor,
              controller: controller,
              behavior: FlashBehavior.fixed,
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
            ),
          );
        },
      );

      return;
    }

    if (model.totalCartQuantity == 0) {
      if (widget.isModal == true) {
        try {
          ExpandingBottomSheet.of(context)!.close();
        } catch (e) {
          Navigator.of(context).pushNamed(RouteList.dashboard);
        }
      } else {
        final modalRoute = ModalRoute.of(context);
        if (modalRoute?.canPop ?? false) {
          Navigator.of(context).pop();
          return;
        }
        MainTabControlDelegate.getInstance().tabAnimateTo(0);
      }
    } else if (isLoggedIn || kPaymentConfig['GuestCheckout'] == true) {
      doCheckout();
    } else {
      _loginWithResult(context);
    }
  }

  Future<void> doCheckout() async {
    showLoading();
    await Services().widget.doCheckout(
      context,
      success: () async {
        hideLoading('');

        FirebaseAnalyticsService.checkout({
          'total': Provider.of<CartModel>(context, listen: false)
                  .checkout
                  ?.totalPrice ??
              0,
          'items': Provider.of<CartModel>(context, listen: false)
              .item
              .values
              .map((e) => (e?.name ?? ''))
              .toList()
        });
        await FluxNavigate.pushNamed(
          RouteList.checkout,
          arguments: CheckoutArgument(isModal: widget.isModal),
          forceRootNavigator: true,
        );
      },
      error: (message) async {
        if (message ==
            Exception('Token expired. Please logout then login again')
                .toString()) {
          setState(() {
            isLoading = false;
          });
          //logout
          final userModel = Provider.of<UserModel>(context, listen: false);
          await userModel.logout();
          Services().firebase.signOut();

          _loginWithResult(context);
        } else {
          hideLoading(message);
          Future.delayed(const Duration(seconds: 3), () {
            setState(() => errMsg = '');
          });
        }
      },
      loading: (isLoading) {
        setState(() {
          this.isLoading = isLoading;
        });
      },
    );
  }

  void showLoading() {
    setState(() {
      isLoading = true;
      errMsg = '';
    });
  }

  void hideLoading(error) {
    setState(() {
      isLoading = false;
      errMsg = error;
    });
  }
}
