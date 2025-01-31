import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/monero/wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/security_backup.dart';
import 'package:cupcake/views/settings.dart';
import 'package:cupcake/views/widgets/drawer_element.dart';
import 'package:flutter/cupertino.dart';

class DrawerElements extends StatelessWidget {
  const DrawerElements({super.key, required this.coinWallet});

  final CoinWallet coinWallet;

  Future<void> _walletList(BuildContext context) async {
    await HomeScreen.staticPush(
      context,
      openLastWallet: false,
      lastOpenedWallet: coinWallet.walletName,
    );
  }

  Future<void> _securityBackup(BuildContext context) async {
    await SecurityBackup.staticPush(context, coinWallet);
  }

  Future<void> _exportKeyImages(BuildContext context) async {
    if (coinWallet is! MoneroWallet) {
      throw Exception("coinWallet is not monero - we can't export key images");
    }
    await (coinWallet as MoneroWallet).exportKeyImagesUR(context);
  }

  Future<void> _otherSettings(BuildContext context) async {
    await SettingsView.staticPush(context);
  }

  @override
  Widget build(BuildContext context) {
    final L = AppLocalizations.of(context)!;
    return Column(
      children: [
        DrawerElement(
          svg: Assets.drawerIcons.wallets.svg(),
          text: L.wallets,
          action: _walletList,
        ),
        DrawerElement(
          svg: Assets.drawerIcons.securityAndBackup.svg(),
          text: L.security_and_backup,
          action: _securityBackup,
        ),
        DrawerElement(
          svg: Assets.drawerIcons.exportKeyImages.svg(),
          text: L.export_key_images,
          action: _exportKeyImages,
        ),
        DrawerElement(
          svg: Assets.drawerIcons.otherSettings.svg(),
          text: L.other_settings,
          action: _otherSettings,
        ),
      ],
    );
  }
}
