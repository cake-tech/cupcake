import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cup_cake/const/resource.dart';

class DrawerElement extends StatelessWidget {
  const DrawerElement({
    super.key,
    required this.svgAsset,
    required this.text,
    required this.action,
  });

  final String svgAsset;
  final String text;
  final Future<void> Function(BuildContext context) action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => action(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SvgPicture.asset(svgAsset),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerElements extends StatelessWidget {
  const DrawerElements({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_WALLETS_SVG,
            text: "Wallets",
            action: (_) async {}),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_ADDRESS_BOOK_SVG,
            text: "Address book",
            action: (_) async {}),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_SECURITY_AND_BACKUP_SVG,
            text: "Security and backup",
            action: (_) async {}),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_EXPORT_KEY_IMAGES_SVG,
            text: "Export key images",
            action: (_) async {}),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_OTHER_SETTINGS_SVG,
            text: "Other settings",
            action: (_) async {}),
        const Divider(),
      ],
    );
  }
}
