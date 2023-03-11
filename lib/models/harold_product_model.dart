import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/http_service.dart';
import 'entities/harold_product.dart';
import 'entities/product.dart';

class HaroldProductModel with ChangeNotifier {
  final Product product;
  HaroldProduct? _haroldProduct;
  bool _isLoading = false;
  bool _videoError = false;

  HaroldProductModel({required this.product});

  HaroldProduct? get haroldProduct => _haroldProduct;

  bool get isLoading => _isLoading;

  bool get videoError => _videoError;

  void setLoading(bool load) {
    _isLoading = load;
    notifyListeners();
  }

  Future<HaroldProduct?> getDetailedHaroldProductModel() async {
    var decoded = utf8.decode(base64.decode(product.id!));
    var productUrl = decoded.split('/');
    var productId = productUrl.last;
    try {
      _videoError = false;
      setLoading(true);
      String? result = await HTTPService.getApi(
          endPoint: 'http://159.89.164.134:8000/mobile/v1/product/$productId');
      _videoError = false;
      setLoading(false);
      _haroldProduct = HaroldProduct.fromJson(jsonDecode(result));
      return _haroldProduct;
    } catch (e) {
      _videoError = true;
      setLoading(false);
    }
    return null;
  }

  List<String> getVideoUrlsFromHaroldProduct() {
    if (_haroldProduct != null) {
      if (_haroldProduct!.crmDetails.videos != null) {
        return _haroldProduct!.crmDetails.videos!
            .map((e) => 'http://159.89.164.134:8000$e')
            .toList();
      }
      return [];
    }
    return [];
  }
}
