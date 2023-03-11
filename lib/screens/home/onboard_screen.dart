// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel;
import 'change_language_mixin.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen();

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> with ChangeLanguage {
  final isRequiredLogin = config.kLoginSetting['IsRequiredLogin'];
  int page = 0;

  List<ContentConfig> getSlides(List<dynamic> data) {
    final slides = <ContentConfig>[];

    Widget renderLoginWidget(String imagePath) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image.asset(
            imagePath,
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);
                    await Navigator.pushReplacementNamed(
                        context, RouteList.register);
                  },
                  child: Text(
                    S.of(context).signIn,
                    style: const TextStyle(
                      color: kTeal400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                const Text(
                  '    |    ',
                  style: TextStyle(color: kTeal400, fontSize: 20.0),
                ),
                GestureDetector(
                  onTap: () async {
                    var prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seen', true);
                    await Navigator.pushReplacementNamed(
                        context, RouteList.register);
                  },
                  child: Text(
                    S.of(context).signUp,
                    style: const TextStyle(
                      color: kTeal400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    for (var i = 0; i < data.length; i++) {
      var slide = ContentConfig(
          // title: data[i]['title'],
          // widgetDescription: ,
          // description: data[i]['desc'],
          // marginTitle: const EdgeInsets.only(
          //   top: 125.0,
          //   bottom: 50.0,
          // ),
          backgroundImageFit: BoxFit.cover,
          widgetDescription: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 2.3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  data[i]['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xffD0AD53),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BebasNeue'),
                ),
                Text(
                  data[i]['desc'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 10),
                Text(
                  data[i]?['desc2'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          backgroundNetworkImage: data[i]['image']
          // backgroundImage: data[i]['image'],
          );

      slides.add(slide);
    }
    return slides;
  }

  void onTapDone() async {
    if (isRequiredLogin) {
      return;
    }
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    await Navigator.pushReplacementNamed(context, RouteList.dashboard);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = config.onBoardingData;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Consumer<AppModel>(builder: (context, _, __) {
            return Container(
              key: UniqueKey(),
              child: IntroSlider(
                listContentConfig: getSlides(data),
                isShowSkipBtn: false,
                isShowPrevBtn: true,
                indicatorConfig: IndicatorConfig(
                  colorIndicator: Colors.white.withOpacity(0.3),
                  colorActiveIndicator: Colors.white,
                ),
                renderSkipBtn: Text(
                  S.of(context).skip,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
                renderDoneBtn: Text(
                  isRequiredLogin ? '' : S.of(context).done.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
                renderPrevBtn: Text(
                  S.of(context).prev.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
                renderNextBtn: Text(
                  S.of(context).next.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
                isShowDoneBtn: !isRequiredLogin,
                onDonePress: onTapDone,
              ),
            );
          }),
          // iconLanguage(),
        ],
      ),
    );
  }
}
