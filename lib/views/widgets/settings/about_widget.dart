import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  Future<void> showWidget(final BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String appName = packageInfo.appName;
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: appName,
      applicationVersion: "$version+$buildNumber",
    );
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

  String? title;

  Future<void> _debugTrigger() async {
    if (easterEgg.isEmpty) {
      if (CupcakeConfig.instance.debug) return;
      CupcakeConfig.instance.debug = true;
      CupcakeConfig.instance.save();
      setState(() {
        title = "debug options enabled";
      });
      return;
    }
    easterEgg.shuffle();
    setState(() {
      title = easterEgg.removeAt(0);
    });
  }

  @override
  Widget build(final BuildContext context) {
    final L = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: title != null ? _debugTrigger : () => showWidget(context),
      onLongPress: _debugTrigger,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF1B284A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Assets.icons.nav.cupcake.svg(width: 24, height: 24),
          const SizedBox(width: 16),
          Text(
            title ?? L.about_the_app,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
