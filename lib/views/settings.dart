import 'package:cupcake/utils/alert.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/settings_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsView extends AbstractView {
  SettingsView({super.key});

  @override
  SettingsViewModel get viewModel => SettingsViewModel();

  static staticPush(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) => SettingsView(),
      ),
    );
  }

  Future<void> postUpdate(BuildContext context) async {
    viewModel.appConfig.save();
    markNeedsBuild();
  }

  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [
        if (config.debug)
          BooleanConfigElement(
              title: "Debug",
              subtitleEnabled: "Debug options are enabled",
              subtitleDisabled: "Debug options are disabled",
              value: viewModel.appConfig.debug,
              onChange: (bool value) {
                viewModel.appConfig.debug = value;
                postUpdate(context);
              }),
        IntegerConfigElement(
            title: "Milliseconds for qr code",
            hint:
                "How many milliseconds should one QR code last before switching to next one",
            value: viewModel.appConfig.msForQrCode,
            onChange: (int value) {
              viewModel.appConfig.msForQrCode = value;
              postUpdate(context);
            }),
        // BooleanConfigElement(
        //     title: "Biometric auth",
        //     subtitleEnabled: "Biometrics are enabled",
        //     subtitleDisabled:
        //         "In order to enable biometrics long press confirm button when entering pin",
        //     value: config.biometricEnabled,
        //     onChange: (bool value) async {
        //       if (value) return;
        //       config.biometricEnabled = false;
        //       final map = await secureStorage.readAll();
        //       for (var key in map.keys) {
        //         if (map[key]!.startsWith("UI.")) {
        //           await secureStorage.delete(key: key);
        //         }
        //       }
        //       config.save();
        //       postUpdate(context);
        //     }),
        IntegerConfigElement(
          title: "Max fragment density",
          hint:
              "How many characters of data should fit within a single QR code",
          value: viewModel.appConfig.maxFragmentLength,
          onChange: (int value) {
            viewModel.appConfig.maxFragmentLength = value;
            postUpdate(context);
          },
        ),
        const VersionWidget(),
      ],
    );
  }
}

class VersionWidget extends StatefulWidget {
  const VersionWidget({super.key});

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  Future<void> showWidget(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    showAboutDialog(
        context: context,
        applicationName: appName,
        applicationVersion: "$version+$buildNumber");
  }

  List<String?> easterEgg = [
    "¯\\_(ツ)_/¯", // Shrug
    "( ͡° ͜ʖ ͡°)", // Lenny Face
    "(╯°□°）╯︵ ┻━┻", // Table Flip
    "┬─┬ ノ( ゜-゜ノ)", // Table Unflip
    "ಠ_ಠ", // Disapproval Look
    "(ಥ﹏ಥ)", // Crying
    "ʕ•ᴥ•ʔ", // Bear Hug
    "（ ^_^）o自自o（^_^ ）", // Cheers!
    "✨🌟✨", // Sparkles
    // New ASCII-only additions
    "+(._.)+", // Robot Face
    "<(o_o<)", // Kirby Dance
    "(>'-')> <('-'<)", // High Five!
    "d(^_^)b", // Thumbs Up
    "(* ^ ω ^)", // Cute Smiling Face
    "(\\__/)", // Bunny
    "(^._.^)ﾉ", // Cat waving
    "ʕ •́؈•̀ ₎", // Angry Bear
    "/ᐠ｡‸｡ᐟ\\", // Kitty Frustrated
    "| (• ◡•)|", // Simple Smiling Face
    "<('o'<)", // Happy Kirby
    "(-'-)=o", // Fighting Stance
    "/╲/( •̀ ω •́ )╯", // Action Pose
    "ʕง•ᴥ•ʔง", // Flexing Bear
    "(.❛ ᴗ ❛.)", // Smiling Face
    "(╥_╥)", // Sad Crying
    "(ง'̀-'́)ง", // Fight Me!
    "(ノಠ益ಠ)ノ", // Rage Flip
  ];

  String? subtitle;

  Future<void> _debugTrigger() async {
    if (easterEgg.isEmpty) {
      if (config.debug) return;
      config.debug = true;
      config.save();
      setState(() {
        subtitle = "debug options enabled";
      });
      Navigator.of(context).pop();
      return;
    }
    easterEgg.shuffle();
    setState(() {
      subtitle = easterEgg.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("About the app"),
      subtitle: subtitle == null ? null : Text(subtitle ?? "..."),
      onTap: subtitle != null ? _debugTrigger : () => showWidget(context),
      onLongPress: _debugTrigger,
    );
  }
}

class IntegerConfigElement extends StatelessWidget {
  IntegerConfigElement({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChange,
  });

  final String title;
  final String? hint;
  final int value;
  final Function(int val) onChange;
  late final ctrl = TextEditingController(text: value.toString());
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onLongPress: () {
        config.debug = true;
        config.save();
      },
      subtitle: TextField(
        controller: ctrl,
        onSubmitted: (String value) {
          final i = int.tryParse(value);
          if (i == null) return;
          onChange(i);
        },
      ),
      trailing: hint == null
          ? null
          : IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showAlertWidget(
                    context: context, title: title, body: [Text(hint ?? "")]);
              },
            ),
    );
  }
}

class BooleanConfigElement extends StatelessWidget {
  const BooleanConfigElement({
    super.key,
    required this.title,
    required this.subtitleEnabled,
    required this.subtitleDisabled,
    required this.value,
    required this.onChange,
  });

  final String title;
  final String subtitleEnabled;
  final String subtitleDisabled;
  final bool value;
  final Function(bool val) onChange;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(value ? subtitleEnabled : subtitleDisabled),
      value: value,
      onChanged: (bool? value) {
        onChange(value == true);
      },
    );
  }
}
