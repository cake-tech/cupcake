import 'dart:io';

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class RestoreLitecoinWalletCreationMethod extends CreationMethod {
  RestoreLitecoinWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seed,
    this.progressCallback,
  });
  final coin = Litecoin();
  final AppLocalizations L;

  final ProgressCallback? progressCallback;
  final String walletPath;
  final String walletPassword;
  final String seed;

  @override
  Future<CreationOutcome> create() async {
    progressCallback?.call(description: L.generating_polyseed);
    // ignore: deprecated_member_use
    final mnemonic = await Mnemonic.fromString(seed);

    final keys = "${Litecoin().getPathForWallet(p.basename(walletPath))}.keys";
    final keysEncrypted = DefaultEncryption().encryptString(mnemonic.asString(), walletPassword);
    File(keys).writeAsBytesSync(keysEncrypted);

    final wallet = await coin.createWalletObject(mnemonic.asString());
    return CreationOutcome(
      method: CreateMethod.restore,
      success: true,
      wallet: LitecoinWallet(
        wallet,
        seed: mnemonic.asString(),
        walletName: p.basename(walletPath),
      ),
    );
  }
}
