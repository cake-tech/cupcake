import 'dart:async';
import 'dart:ui';

import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/panic_handler.dart';
import 'package:cupcake/themes/base_theme.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBaseStoragePath();
  if (CupcakeConfig.instance.initialSetupComplete == false) {
    final oldSecureStorage = await secureStorage.readAll();
    final date = DateTime.now().toIso8601String();
    CupcakeConfig.instance.oldSecureStorage[date] = oldSecureStorage;
    CupcakeConfig.instance.save();
    await secureStorage.deleteAll();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (final FlutterErrorDetails errorDetails) {
    catchFatalError(errorDetails.exception, null);
  };
  PlatformDispatcher.instance.onError = (final Object error, final StackTrace stackTrace) {
    catchFatalError(error, stackTrace);
    return true;
  };
  await _main();
}

Future<void> _main() async {
  await appInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cupcake',
      themeMode: ThemeMode.dark,
      darkTheme: BaseTheme.darkBaseTheme,
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
      home: CupcakeConfig.instance.initialSetupComplete
          ? HomeScreen(
              openLastWallet: true,
            )
          : InitialSetupScreen(),
    );
  }
}
