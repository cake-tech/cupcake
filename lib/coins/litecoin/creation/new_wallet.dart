import 'dart:io';

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class CreateLitecoinWalletCreationMethod extends CreationMethod {
  CreateLitecoinWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    this.progressCallback,
  });
  final coin = Litecoin();
  final AppLocalizations L;

  final ProgressCallback? progressCallback;
  final String walletPath;
  final String walletPassword;

  @override
  Future<CreationOutcome> create() async {
    progressCallback?.call(description: L.generating_polyseed);
    // ignore: deprecated_member_use
    final mnemonic = await Mnemonic.create(WordCount.words12);

    final keys = "${Litecoin().getPathForWallet(p.basename(walletPath))}.keys";
    final keysEncrypted = DefaultEncryption().encryptString(mnemonic.asString(), walletPassword);
    File(keys).writeAsBytesSync(keysEncrypted);

    final wallet = await coin.createWalletObject(mnemonic.asString());
    return CreationOutcome(
      method: CreateMethod.create,
      success: true,
      wallet: LitecoinWallet(
        wallet,
        seed: mnemonic.asString(),
        walletName: p.basename(walletPath),
      ),
    );
  }
}
