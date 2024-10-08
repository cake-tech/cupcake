import 'package:cup_cake/l10n/app_localizations.dart';
import 'package:cup_cake/themes/base_theme.dart';
import 'package:cup_cake/utils/config.dart';
import 'package:cup_cake/utils/filesystem.dart';
import 'package:cup_cake/view_model/home_screen_view_model.dart';
import 'package:cup_cake/views/home_screen.dart';
import 'package:cup_cake/views/initial_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      darkTheme: darkBaseTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('pl'), // Polish
      ],
      home: config.initialSetupComplete
          ? HomeScreen(
              viewModel: HomeScreenViewModel(openLastWallet: true),
            )
          : InitialSetupScreen(),
    );
  }
}
