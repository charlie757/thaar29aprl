// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  //App related strings
  static String appName = "Thaar Transport";

  //Colors for theme

  static Color maincolor = Color(0XFF142438);
  static Color thaartheme = Color(0xff183038);
  static Color trucktheme = Colors.red;
  static Color shippertheme = Colors.green;
  static Color white = Color(0xffffffff);
  static Color bnbhover = Color(0xff183038);

  static Color btnBG = Color(0xff182020);
  static Color lightbtnBG = Color(0xfff0f0f0);
  static Color labelcolor = Color(0xff202880);
  static Color floatingbtnBG = Color(0xffc0e4fc);
  static Color btninactive = Color(0xffCCCCCC);
  static Color btntextactive = Color(0xff0D2C40);
  static Color btntextinactive = Color(0xffC3C3C3);
  static Color borderColor = Color(0xffF8A828);

  static Color alert = Color(0xffd81848);
  static Color h2lhbg = Color(0xfff0e8f0);

  static Color redwhitelight = Color(0xfff0e8f0);
  static Color inactivedot = Color(0xff707878);
  static Color activedot = Color(0xff183850);
  static Color textfieldborder = Color(0xff102838);
  static Color cursorColor = Color(0xff08b878);

  static Color lightPrimary = Color(0xfff3f4f9);
  static Color darkPrimary = Color(0xff2B2B2B);

  static Color lightAccent = Color(0xff886EE4);

  static Color darkAccent = Color(0xff886EE4);

  static Color lightBG = Color(0xfff3f4f9);
  static Color darkBG = Color(0xff2B2B2B);
  TextStyle h1 = TextStyle();

  static ThemeData lightTheme = ThemeData(
    appBarTheme: AppBarTheme(color: Constants.btnBG),
  );
}
