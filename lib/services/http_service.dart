// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

const String networkErrorMessage = 'Failed to execute the network call.';

class HTTPService {
  static Future<dynamic> postApi(
      {required Map<String, Map<String, Object>> map,
      required String endPoint}) async {
    final response = await post(
      Uri.parse(endPoint),
      body: jsonEncode(map),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
    //print(jsonEncode(map));
    if (response.statusCode == 200) {
      print(response.statusCode);
      //print(response.body);
      return response.body;
    } else {
      throw Exception(networkErrorMessage);
    }
  }

  static Future<String> putApi(
      {required Map<String, dynamic> map, required String endPoint}) async {
    final response = await put(Uri.parse(endPoint), body: map);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(networkErrorMessage);
    }
  }

  static Future<dynamic> getApii({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(endPoint).replace(queryParameters: queryParameters);
    print('uri is $uri');
    final response = await get(uri);
    //log('response body is ${response.body}');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(networkErrorMessage);
    }
  }

  static Future<String> getApi({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(endPoint).replace(queryParameters: queryParameters);
    print('uri is $uri');
    final response = await get(uri);
    log('response body is ${response.body}');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(networkErrorMessage);
    }
  }
}
