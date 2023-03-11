import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

TextTheme buildTextTheme(
  TextTheme base,
  String? language, {
  String? customFont,
  String fontFamily = 'Roboto',
  String fontHeader = 'Raleway',
}) {
  return customFont != null
      ? base
          .copyWith(
            headline1: base.headline1!.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headline2: base.headline1!
                .copyWith(fontWeight: FontWeight.w700, fontFamily: customFont),
            headline3: base.headline3!
                .copyWith(fontWeight: FontWeight.w700, fontFamily: customFont),
            headline4: base.headline4!
                .copyWith(fontWeight: FontWeight.w700, fontFamily: customFont),
            headline5: base.headline5!
                .copyWith(fontWeight: FontWeight.w500, fontFamily: customFont),
            headline6: base.headline6!
                .copyWith(fontSize: 18.0, fontFamily: customFont),
            caption: base.caption!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                fontFamily: customFont),
            subtitle1: base.subtitle1!.copyWith(
              fontFamily: customFont,
            ),
            subtitle2: base.subtitle2!.copyWith(
              fontFamily: customFont,
            ),
            bodyText1: base.bodyText1!.copyWith(
              fontFamily: customFont,
            ),
            bodyText2: base.bodyText1!.copyWith(fontFamily: fontFamily),
            button: base.button!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                fontFamily: fontFamily),
          )
          .apply(
            displayColor: kGrey900,
            bodyColor: kGrey900,
          )
      : base
          .copyWith(
            headline1: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline1!.copyWith(
                fontWeight: FontWeight.w700,

                /// If using the custom font, un-comment below and clone to other headline.., bodyText..
                fontFamily: customFont,
              ),
            ),
            headline2: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline1!.copyWith(
                  fontWeight: FontWeight.w700, fontFamily: customFont),
            ),
            headline3: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline3!.copyWith(
                  fontWeight: FontWeight.w700, fontFamily: customFont),
            ),
            headline4: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline4!.copyWith(
                  fontWeight: FontWeight.w700, fontFamily: customFont),
            ),
            headline5: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline5!.copyWith(
                  fontWeight: FontWeight.w500, fontFamily: customFont),
            ),
            headline6: GoogleFonts.getFont(
              fontHeader,
              textStyle: base.headline6!
                  .copyWith(fontSize: 18.0, fontFamily: customFont),
            ),
            caption: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.caption!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.0,
                  fontFamily: customFont),
            ),
            subtitle1: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.subtitle1!.copyWith(
                fontFamily: customFont,
              ),
            ),
            subtitle2: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.subtitle2!.copyWith(
                fontFamily: customFont,
              ),
            ),
            bodyText1: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.bodyText1!.copyWith(
                fontFamily: customFont,
              ),
            ),
            bodyText2: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.bodyText1!.copyWith(fontFamily: customFont),
            ),
            button: GoogleFonts.getFont(
              fontFamily,
              textStyle: base.button!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.0,
                  fontFamily: customFont),
            ),
          )
          .apply(
            displayColor: kGrey900,
            bodyColor: kGrey900,
          );
}
