import 'dart:io';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/bitcoin/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class RestoreBitcoinWalletCreationMethod extends CreationMethod {
  RestoreBitcoinWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seed,
    required this.passphrase,
    this.progressCallback,
  });
  final coin = Bitcoin();
  final AppLocalizations L;

  final ProgressCallback? progressCallback;
  final String walletPath;
  final String walletPassword;
  final String seed;
  final String passphrase;

  @override
  Future<CreationOutcome> create() async {
    progressCallback?.call(description: L.generating_polyseed);
    // ignore: deprecated_member_use
    final mnemonic = await Mnemonic.fromString(seed);

    final keys = "${Bitcoin().getPathForWallet(p.basename(walletPath))}.keys";
    final data = passphrase.isEmpty ? mnemonic.asString() : "${mnemonic.asString()};$passphrase";
    final keysEncrypted = DefaultEncryption().encryptString(data, walletPassword);
    File(keys).writeAsBytesSync(keysEncrypted);

    final wallet = await coin.createWalletObject(mnemonic.asString(), passphrase);
    return CreationOutcome(
      method: CreateMethod.restore,
      success: true,
      wallet: BitcoinWallet(
        wallet,
        seed: mnemonic.asString(),
        walletName: p.basename(walletPath),
        passphrase: passphrase,
      ),
    );
  }
}
