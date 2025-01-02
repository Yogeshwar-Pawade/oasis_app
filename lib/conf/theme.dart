import 'package:flutter/material.dart';

// Colors for Dark Theme
final Color darkPrimaryColor = Colors.black;
final Color darkTextColor = Colors.white;

// Dark Theme Background
final BoxDecoration darkGradientBackground = BoxDecoration(
  color: Colors.black,
);

// Colors for Light Theme
final Color lightPrimaryColor = Colors.white;
final Color lightTextColor = Colors.black;

// Light Theme Background
final BoxDecoration lightGradientBackground = BoxDecoration(
  color: Colors.white,
);

// Define Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: Colors.transparent, // Background will be handled globally
  textTheme: TextTheme(
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryColor,
    iconTheme: IconThemeData(color: darkTextColor),
    titleTextStyle: TextStyle(
      color: darkTextColor,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
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

// Define Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimaryColor,
  scaffoldBackgroundColor: Colors.transparent, // Background will be handled globally
  textTheme: TextTheme(
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: lightPrimaryColor,
    iconTheme: IconThemeData(color: lightTextColor),
    titleTextStyle: TextStyle(
      color: lightTextColor,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: lightPrimaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lightPrimaryColor,
    foregroundColor: lightTextColor,
  ),
);

// Access Gradient Backgrounds Based on Theme
BoxDecoration getGradientBackground(Brightness brightness) {
  return brightness == Brightness.dark
      ? darkGradientBackground
      : lightGradientBackground;
}