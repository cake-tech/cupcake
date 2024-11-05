import 'package:flutter/material.dart';

const baseBackgroundColor = Color.fromRGBO(25, 35, 60, 1);
const onBackgroundColor = Color.fromRGBO(35, 44, 79, 1);
const onOnBackgroundColor = Color.fromRGBO(35, 55, 93, 1);
const buttonBorderColor = Color.fromRGBO(79, 91, 121, 1);

final darkBaseTheme = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: baseBackgroundColor,
  cardTheme: const CardTheme(
    color: onBackgroundColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: onOnBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(
          color: Colors.white,
        )),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: baseBackgroundColor,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Color.fromRGBO(99, 113, 150, 1)),
    bodySmall: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
  ).apply(fontFamily: "Lato"),
  dividerColor: onOnBackgroundColor,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.transparent,
  ),
);
