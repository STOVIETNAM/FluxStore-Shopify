import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../services/http_service.dart';

class RequestCallbackModel with ChangeNotifier {
  bool _isLoading = false;
  String? _selectedInquiry;
  final String _postEndPoint =
      'http://159.89.164.134:8000/mobile/v1/home/pushEnquiry';
  final List<String> _enquiryDropdownData = [
    'Looking for lighting consultation',
    'Need lights for entire house',
    'I am an interior / architect',
    'Looking for duplex chandelier',
    'Others'
  ];

  bool get isLoading => _isLoading;

  List<String> get enquiryDropdownData => _enquiryDropdownData;

  String? get selectedInquiry => _selectedInquiry;

  void setSelectedInquiry(String inquiry) {
    _selectedInquiry = inquiry;
    notifyListeners();
  }

  void setLoading(bool load) {
    _isLoading = load;
    notifyListeners();
  }

  void requestCallback(
      {required String name,
      required String phoneNumber,
      String? inquiry,
      Function? onSuccess,
      Function(String error)? onError}) async {
    const errorMsg = 'We couldn\'t send your request. Please try again';
    try {
      if (name.isEmpty || phoneNumber.isEmpty) {
        if (onError != null) {
          onError('Please make sure you have entered all fields.');
        }
      }
      final queryParameters = {
        'name': name,
        'contactNumber': phoneNumber,
        'query': inquiry ?? _selectedInquiry ?? ''
      };
      log('Query Params is $queryParameters');
      setLoading(true);
      final response = await HTTPService.getApi(
          endPoint: _postEndPoint, queryParameters: queryParameters);
      setLoading(false);
      final decodedResponse = jsonDecode(response);
      if (decodedResponse['succesfull'] == true) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(errorMsg);
      }
    } catch (e) {
      setLoading(false);
      if (onError != null) {
        onError(errorMsg);
      }
    }
  }

  String? validateMobile(String value) {
    var patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    var regExp = RegExp(patttern);
    if (value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }
}
