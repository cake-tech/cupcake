import 'dart:async';
import 'dart:ui';

import 'package:applock/applock.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/panic_handler.dart';
import 'package:cupcake/themes/base_theme.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBaseStoragePath();
  if (await CupcakeConfig.instance.initialSetupComplete() == false) {
    final oldSecureStorage = await secureStorage.readAll();
    final date = DateTime.now().toIso8601String();
    CupcakeConfig.instance.oldSecureStorage[date] = oldSecureStorage;
    CupcakeConfig.instance.save();
    await secureStorage.deleteAll();
  }
}

const List<String> ignoredErrors = [];

Future<void> enableErrorHandling() async {
  FlutterError.onError = (final FlutterErrorDetails errorDetails) {
    if (ignoredErrors.any((final e) => errorDetails.exception.toString().contains(e))) {
      return;
    }
    catchFatalError(errorDetails.exception, null);
  };
  PlatformDispatcher.instance.onError = (final Object error, final StackTrace stackTrace) {
    if (ignoredErrors.any((final e) => error.toString().contains(e))) {
      return true;
    }
    catchFatalError(error, stackTrace);
    return true;
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode) {
    unawaited(enableErrorHandling());
  }
  await AppLock.instance.registerAppStart(BaseTheme.darkBaseTheme, $main);
}

Future<void> $main() async {
  await appInit();
  final initialSetupComplete = await CupcakeConfig.instance.initialSetupComplete();
  runApp(MyApp(initialSetupComplete: initialSetupComplete));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialSetupComplete});
  final bool initialSetupComplete;

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
      home: initialSetupComplete
          ? HomeScreen(
              openLastWallet: true,
            )
          : InitialSetupScreen(),
    );
  }
}
