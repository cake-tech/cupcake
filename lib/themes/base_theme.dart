import 'package:flutter/material.dart';

class BaseTheme {
  static const baseBackgroundColor = Color(0xff1B284A);
  static const onBackgroundColor = Color.fromRGBO(35, 44, 79, 1);
  static const onOnBackgroundColor = Color.fromRGBO(35, 55, 93, 1);
  static const buttonBorderColor = Color.fromRGBO(79, 91, 121, 1);

  static final darkBaseTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: baseBackgroundColor,
    cardTheme: const CardThemeData(
      color: onBackgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: onOnBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
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
    colorScheme: ColorScheme.dark(
      primary: Color(0xff91B0FF),
      secondary: Color(0xff91A7FF),
      onPrimary: Color(0xff002860),
      surface: Color(0xff233461),
      onSecondaryContainer: Color(0xffBACBFF),
      onSurface: Color(0xffD7E2F7),
      onSurfaceVariant: Color(0xff8C9FBB),
      surfaceContainerHighest: Color(0xff334C8C),
      surfaceContainerLowest: Color(0xff131C33),
      onError: Color(0xff690005),
    ),
    primaryColor: Color(0xff91B0FF),
  );
}
