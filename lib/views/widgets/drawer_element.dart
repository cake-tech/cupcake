import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/monero/wallet.dart';
import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/views/home_screen.dart';
import 'package:cup_cake/views/security_backup.dart';
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
      onTap: () {
        callThrowable(context, () async => await action(context), text);
      },
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerElements extends StatelessWidget {
  const DrawerElements({super.key, required this.coinWallet});

  final CoinWallet coinWallet;

  Future<void> _walletList(BuildContext context) async {
    HomeScreen.staticPush(context, openLastWallet: false);
  }

  Future<void> _addressBook(BuildContext context) async {
    throw UnimplementedError("Address book is not implemented");
  }

  Future<void> _securityBackup(BuildContext context) async {
    SecurityBackup.staticPush(context, coinWallet);
  }

  Future<void> _exportKeyImages(BuildContext context) async {
    if (coinWallet is! MoneroWallet) {
      throw Exception("coinWallet is not monero - we can't export key images");
    }
    await (coinWallet as MoneroWallet).exportKeyImagesUR(context);
  }

  Future<void> _otherSettings(BuildContext context) async {
    throw UnimplementedError("Other settings are not implemented");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerElement(
          svgAsset: R.ASSETS_DRAWER_ICONS_WALLETS_SVG,
          text: "Wallets",
          action: _walletList,
        ),
        const Divider(),
        DrawerElement(
          svgAsset: R.ASSETS_DRAWER_ICONS_ADDRESS_BOOK_SVG,
          text: "Address book",
          action: _addressBook,
        ),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_SECURITY_AND_BACKUP_SVG,
            text: "Security and backup",
            action: _securityBackup),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_EXPORT_KEY_IMAGES_SVG,
            text: "Export key images",
            action: _exportKeyImages),
        const Divider(),
        DrawerElement(
            svgAsset: R.ASSETS_DRAWER_ICONS_OTHER_SETTINGS_SVG,
            text: "Other settings",
            action: _otherSettings),
        const Divider(),
      ],
    );
  }
}
