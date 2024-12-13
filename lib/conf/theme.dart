import 'package:flutter/material.dart';

// Define Dark Theme Colors
final Color darkBackgroundColor = Color(0xFF080833);
final Color darkPrimaryColor = Color(0xFF4A2DB3);
final Color darkTextColor = Colors.white;

// Dark Theme Data
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: darkBackgroundColor,
  textTheme: TextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryColor,
    iconTheme: IconThemeData(color: darkTextColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: darkPrimaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkPrimaryColor,
    foregroundColor: darkTextColor,
  ),
);