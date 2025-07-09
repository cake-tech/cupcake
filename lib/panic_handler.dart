import 'package:cupcake/themes/base_theme.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// This page is intentionally not translated
// and it intentionally doesn't use MVVM or pretty much anything from the app, as the main goal of
// this page is to collect error when thing didn't go exactly as expected.
// Ideally users will nevel see this :)

Future<void> catchFatalError(
  final Object error,
  final StackTrace? stackTrace,
) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  runApp(
    ErrorHandlerApp(
      error: error,
      stackTrace: stackTrace,
      packageInfo: packageInfo,
    ),
  );
}

class ErrorHandlerApp extends StatelessWidget {
  const ErrorHandlerApp({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.packageInfo,
  });

  final Object error;
  final StackTrace? stackTrace;
  final PackageInfo packageInfo;
  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cupcake Crash',
      themeMode: ThemeMode.dark,
      darkTheme: BaseTheme.darkBaseTheme,
      home: CupcakeFatalError(
        error: error,
        stackTrace: stackTrace,
        packageInfo: packageInfo,
      ),
    );
  }
}

class CupcakeFatalError extends StatelessWidget {
  const CupcakeFatalError({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.packageInfo,
  });

  final Object error;
  final StackTrace? stackTrace;
  final PackageInfo packageInfo;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Oops!"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._buildNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(final dynamic element) {
    return SelectableText(
      element.toString(),
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  List<Widget> _buildNotice() {
    return [
      _text("Critical error occured and app cannot continue. Please take a screenshot of this"
          " screen and send it to our support"),
      Divider(),
      _text(error),
      Divider(),
      _text("appName: ${packageInfo.appName}"),
      _text("buildNumber: ${packageInfo.buildNumber}"),
      _text("buildSignature: ${packageInfo.buildSignature}"),
      _text("installerStore: ${packageInfo.installerStore}"),
      _text("packageName: ${packageInfo.packageName}"),
      _text("version: ${packageInfo.version}"),
      Divider(),
      _text(stackTrace),
    ];
  }
}
