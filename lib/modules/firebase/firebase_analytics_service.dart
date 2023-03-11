import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

abstract class FirebaseAnalyticsAbs {
  void init() {}
  List<NavigatorObserver> getMNavigatorObservers() {
    return const <NavigatorObserver>[];
  }
}

class FirebaseAnalyticsService extends FirebaseAnalyticsAbs {
  late FirebaseAnalytics analytics;

  static void login() {
    FirebaseAnalytics.instance.logLogin(loginMethod: 'mobileNumber');
  }

  static void signUp() {
    FirebaseAnalytics.instance.logSignUp(signUpMethod: 'mobileNumber');
  }

  static void rateTheApp() {
    FirebaseAnalytics.instance.logEvent(name: 'rate_the_app');
  }

  static void requestCallBack() {
    FirebaseAnalytics.instance.logEvent(name: 'request_call_back');
  }

  static void frenchiseePartner() {
    FirebaseAnalytics.instance.logEvent(name: 'frenchisee_partner');
  }

  static void chatWithUs(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'chat_with_us', parameters: paras);
  }

  static void checkout(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance.logEvent(name: 'checkout', parameters: paras);
  }

  static void addTocart(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance.logAddToCart(
        items: paras['item'],
        value: double.parse(paras['item'][0].price.toString()) *
            double.parse(paras['item'][0].quantity.toString()),
        currency: 'INR');
  }

  static void addToWhish(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance.logAddToWishlist(items: paras['item']);
  }

  static void shareProduct(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance.logEvent(name: 'share_product');
  }

  static void videoProduct(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'play_video_product', parameters: paras);
  }

  static void productCategoty(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'product_category', parameters: paras);
  }

  static void productCategotyBySearch(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'product_category_by_search', parameters: paras);
  }

  static void productDetails(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'product_details', parameters: paras);
  }

  static void homeProductBanner(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'home_product_banner', parameters: paras);
  }

  static void homeRecentProduct(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'home_recent_product', parameters: paras);
  }

  static void haroldCategory(Map<String, dynamic> paras) {
    FirebaseAnalytics.instance
        .logEvent(name: 'harold_category', parameters: paras);
  }
}
