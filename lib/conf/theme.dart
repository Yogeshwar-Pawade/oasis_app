import 'package:flutter/material.dart';

final Color darkPrimaryColor = Color(0xFF4A2DB3);
final Color darkTextColor = Colors.white;

final BoxDecoration darkGradientBackground = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromARGB(255, 7, 5, 48), 
      Colors.black,             
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

// Dark Theme Data
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: Colors.transparent, // We'll use a container to apply the gradient
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