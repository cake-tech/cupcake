import 'package:cupcake/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatefulWidget {
  const VersionWidget({super.key});

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  Future<void> showWidget(final BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String appName = packageInfo.appName;
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;
    if (!context.mounted) return;
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
      if (CupcakeConfig.instance.debug) return;
      CupcakeConfig.instance.debug = true;
      CupcakeConfig.instance.save();
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
  Widget build(final BuildContext context) {
    return ListTile(
      title: const Text("About the app"),
      subtitle: subtitle == null ? null : Text(subtitle ?? "..."),
      onTap: subtitle != null ? _debugTrigger : () => showWidget(context),
      onLongPress: _debugTrigger,
    );
  }
}
