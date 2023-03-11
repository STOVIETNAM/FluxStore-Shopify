import 'package:flutter/material.dart';


class CouponModel with ChangeNotifier {
  List<bool> couponList = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  void changeValue(int index) {
    couponList[index] = !couponList[index];
    notifyListeners();
  }
}
