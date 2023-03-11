import '../../constants.dart';

class ThemeConfig {
  String? mainColor;
  String? logoImage;
  String? backgroundColor;
  String? primaryColorLight;
  String? textColor;
  String? secondaryColor;

  String get logo => logoImage ?? kLogo;

  ThemeConfig({
    this.mainColor,
    this.logoImage,
    this.backgroundColor,
    this.primaryColorLight,
    this.textColor,
    this.secondaryColor,
  });

  ThemeConfig.fromJson(Map config) {
    logoImage = config['logo'];
    mainColor = config['MainColor'];
    backgroundColor = config['backgroundColor'];
    primaryColorLight = config['primaryColorLight'];
    textColor = config['textColor'];
    secondaryColor = config['secondaryColor'];
  }

  Map? toJson() {
    var map = <String, dynamic>{};
    map['MainColor'] = mainColor;
    map['logo'] = logoImage;
    map['backgroundColor'] = backgroundColor;
    map['primaryColorLight'] = primaryColorLight;
    map['textColor'] = textColor;
    map['secondaryColor'] = secondaryColor;
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
