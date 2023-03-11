part of '../constants.dart';

// const appFolder = 'FluxBuilder/';
const appFolder = '';

class LocalStorageKey {
  /// FLUXBUILDER
  static const String loggedIn = '${appFolder}loggedIn';
  static const String app = '${appFolder}fstore';
  static const String notification = '${appFolder}notification';
  static const String blogWishList = '${appFolder}blogWishList';
  static const String recentBlogsSearch = '${appFolder}recentBlogSearch';
  static const String dataOrder = '${appFolder}data_order';
  static const String address = '${appFolder}address';
  static const String userCookie = '${appFolder}userToken';
  static const String instagramLocalKey = '${appFolder}instagram_';

  /// NORMAL APPS
  static const String seen = 'seen';
  static const String seenFortutorial = 'seenForTutorial';
  static const String seenFortutorialProductDetails = 'seenFortutorialProductDetails';
  static const String posAddress = 'posAddress';
}

class FileHelper {
  static Future<String> createAppFolder() async {
    if (appFolder.isEmpty) {
      return '';
    }
    final _appDocDir = await getApplicationDocumentsDirectory();
    final _appDocDirFolder = Directory('${_appDocDir.path}/$appFolder');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}
