import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.blue),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.blue, // Text selection handle color
    selectionColor:
        Color.fromARGB(112, 63, 169, 255), // Text selection background color
    selectionHandleColor:
        Color.fromARGB(112, 63, 169, 255), // Text selection handle color
  ),
);
