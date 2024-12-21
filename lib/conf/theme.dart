import 'package:flutter/material.dart';

// final Color darkPrimaryColor = Color(0xFF4A2DB3);
final Color darkPrimaryColor = Colors.black;
final Color darkTextColor = Colors.white;

// Single color for the background
final BoxDecoration darkGradientBackground = BoxDecoration(
  color: Colors.black,
);

// Dark Theme Data
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: Colors.transparent, // We'll use a container to apply the background
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