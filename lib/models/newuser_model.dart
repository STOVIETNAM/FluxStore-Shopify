// ignore_for_file: omit_local_variable_types, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_single_quotes, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../common/constants.dart';
import '../common/tools/flash.dart';
import '../services/http_service.dart';
import 'entities/newuser.dart';

class NewUserModel with ChangeNotifier {
  // ignore: prefer_final_fields
  List<NewUser> _newUsers = [];
  List<NewUser> get newUsers => [..._newUsers];

  List<Customer> _customers = [];
  List<Customer> get customers => [..._customers];

  Customer? _customer;
  Customer? get customer => _customer;

  set customer(Customer? customer) {
    _customer = customer;
    notifyListeners();
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void setisLoggedIn(bool load) {
    _isLoggedIn = load;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool load) {
    _isLoading = load;
    notifyListeners();
  }

  Future<List<Customer>> createNewUser(
      String phoneNumber,
      String tags,
      String firstname,
      String lastname,
      String email,
      String pincode,
      String address) async {
    var args = {
      "customer": {
        "first_name": firstname,
        if (lastname.isNotEmpty) "last_name": lastname,
        "email": email,
        "phone": phoneNumber,
        "verified_email": false,
        "addresses": [
          {
            "address1": address,
            "city": "",
            "phone": phoneNumber,
            "zip": pincode,
            "last_name": lastname,
            "first_name": firstname,
            "country": ""
          }
        ],
        "password": "",
        "password_confirmation": "",
        "send_email_welcome": false,
        "tags": tags
      }
    };
    try {
      // setLoading(true);
      dynamic response = await HTTPService.postApi(
          map: args, endPoint: 'http://159.89.164.134:8000/mobile/v1/customer');
      print('Response');
      print(response);
      // dynamic extracted = jsonDecode(response);
      // print(extracted);
      if (!response.toString().contains("error")) {
        var map = json.decode(response);
        var data = map['customer'];
        Customer converted = Customer.fromJson(data);
        _customers.add(converted);
        notifyListeners();

        if (_customers.isNotEmpty) {
          saveUserdetails(
            userId: _customers[0].id,
            userName: _customers[0].firstName,
            lastName: _customers[0].lastName,
            userEmail: _customers[0].email,
            userMob: _customers[0].phone,
          );
        }
      } else {
        var map = json.decode(response);

        unawaited(FlashHelper.actionBar(
          App.fluxStoreNavigatorKey.currentContext!,
          title: 'Error',
          presistent: true,
          duration: const Duration(seconds: 3),
          message: "Email " + (map['errors']['email']?[0] ?? ""),
          onPrimaryActionTap: ((controller) {}),
          primaryAction: const SizedBox(),
        ));
      }

      // setLoading(false);
    } catch (e) {
      unawaited(FlashHelper.actionBar(
        App.fluxStoreNavigatorKey.currentContext!,
        title: 'Error',
        presistent: true,
        duration: const Duration(seconds: 3),
        message: 'Please try again',
        onPrimaryActionTap: ((controller) {}),
        primaryAction: const SizedBox(),
      ));
      // setLoading(false);
    }
    return _customers;
  }

  Future updateNewUser(String id, String name, String email, String zipcode,
      String address) async {
    var args = {
      'customer': {
        'first_name': name,
        'email': email,
        'default_address': {'id': id, 'address1': address, 'zip': zipcode}
      }
    };
    try {
      setLoading(true);
      String? result = await HTTPService.putApi(
          map: args,
          endPoint: 'http://159.89.164.134:8000/mobile/v1/customer/$id');
      setLoading(false);
      printLog(result);
    } catch (e) {
      setLoading(false);
    }
  }

  Future<List<Customer>> searchNewUser(String phoneNumber) async {
    try {
      //setLoading(true);
      dynamic result = await HTTPService.getApii(
          endPoint:
              'http://159.89.164.134:8000/mobile/v1/customer/search?phone=$phoneNumber');
      //setLoading(false);
      print('RESULT');
      print(result);
      print(jsonDecode(result));
      var extracted = jsonDecode(result);
      print('NEW USER');
      print(extracted['customers']);
      Map<String, dynamic> map = json.decode(result);
      List<dynamic> data = map['customers'];
      List<Customer> converted = data.map((e) => Customer.fromJson(e)).toList();
      _customers = converted;

      if (_customers.isNotEmpty) {
        saveUserdetails(
          userId: _customers[0].id,
          userName: _customers[0].firstName,
          lastName: _customers[0].lastName,
          userEmail: _customers[0].email,
          userMob: _customers[0].phone,
        );
      }
      //print(data);
      // List<dynamic> extracted = jsonDecode(result);
      // print(extracted);
      // List<NewUser> data = extracted.map((e) => NewUser.fromJson(e)).toList();
      // _newUsers = data;
      // printLog(_newUsers);
      notifyListeners();

      //return _newUsers;
    } catch (e) {
      print(e);
      //setLoading(false);
    }
    return _customers;
  }

//!! add needed files to save locally here
  void saveUserdetails({
    userId,
    userEmail,
    userName,
    lastName,
    userMob,
  }) async {
    final _sharedPreferences = await SharedPreferences.getInstance();
    final userData = json.encode({
      'userid': userId,
      'useremail': userEmail,
      'firstName': userName,
      'lastName': lastName,
      'usermob': userMob,
    });
    await _sharedPreferences.setString('userData', userData);
    print('user saved successfully');
  }

//!! use this function to remove locally saved saved files (logout)
  void clearUser() async {
    final _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('userData');
    print('user removed successfully');
    _customers = [];
    _isLoggedIn = false;
    notifyListeners();
  }
}
