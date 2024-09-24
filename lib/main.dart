import 'package:cup_cake/themes/monero_dark_theme.dart';
import 'package:cup_cake/utils/filesystem.dart';
import 'package:cup_cake/views/home_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBaseStoragePath();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cup Cake',
      themeMode: ThemeMode.dark,
      darkTheme: MoneroDarkTheme(raw: 0).themeData,
      home: HomeScreen(),
    );
  }
}
