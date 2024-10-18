import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/themes/base_theme.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:cupcake/utils/get_signing_key.dart';
import 'package:cupcake/view_model/home_screen_view_model.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const String signingKeyExpected = "Please Fill Me On Release :)";
late String signingKeyFound = "";

Future<void> appInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    signingKeyFound = await getSigningKey() ?? "unknown";
  } catch (e) {
    signingKeyFound = e.toString();
  }
  await initializeBaseStoragePath();
}

Future<void> main() async {
  await appInit();
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
      builder: (BuildContext context, Widget? child) {
        return Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            child ?? const Text("null"),
          ],
        );
      },
      home: config.initialSetupComplete
          ? HomeScreen(
              viewModel: HomeScreenViewModel(openLastWallet: true),
            )
          : InitialSetupScreen(),
    );
  }
}
