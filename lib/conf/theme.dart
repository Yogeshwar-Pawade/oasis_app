import 'package:flutter/material.dart';

// Dark theme colors
final Color darkBackgroundColor = Color(0xFF080833);
final Color darkPrimaryColor = Color(0xFF4A2DB3);
final Color darkTextColor = Colors.white;

// Light theme colors
final Color lightBackgroundColor = Color(0xFFF0F0F0);
final Color lightPrimaryColor = Color(0xFF1E88E5);
final Color lightTextColor = Colors.black;

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
);

// Light Theme Data
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimaryColor,
  scaffoldBackgroundColor: lightBackgroundColor,
  textTheme: TextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: lightPrimaryColor,
    iconTheme: IconThemeData(color: lightTextColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: lightPrimaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
);