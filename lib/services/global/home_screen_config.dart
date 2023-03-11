// ignore_for_file: empty_catches

import 'dart:convert';

import '../http_service.dart';

class HomeScreenConfig {
  static Map<String, dynamic> configFromApi = {};
  static Future<void> getHomeScreenConfig() async {
    try {
      final response = await HTTPService.getApi(
          endPoint: 'http://159.89.164.134:8000/mobile/v1/home/config');

      configFromApi = jsonDecode(response);
    } catch (e) {}
  }
}
