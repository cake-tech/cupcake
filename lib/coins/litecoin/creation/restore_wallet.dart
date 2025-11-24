import 'dart:io';

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:bip39/bip39.dart' as bip39;

class RestoreLitecoinWalletCreationMethod extends CreationMethod {
  RestoreLitecoinWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.passphrase,
    required this.seed,
  });
  final coin = Litecoin();
  final AppLocalizations L;

  final String walletPath;
  final String walletPassword;
  final String passphrase;
  final String seed;

  @override
  Future<CreationOutcome> create() async {
    // ignore: deprecated_member_use
    if (!bip39.validateMnemonic(seed)) {
      return CreationOutcome(
        method: CreateMethod.restore,
        success: false,
        message: 'Invalid mnemonic',
      );
    }
    final mnemonic = seed;

    final keys = "${Litecoin().getPathForWallet(p.basename(walletPath))}.keys";
    final keysEncrypted =
        DefaultEncryption().encryptString("$mnemonic;$passphrase", walletPassword);
    File(keys).writeAsBytesSync(keysEncrypted);

    return CreationOutcome(
      method: CreateMethod.restore,
      success: true,
      wallet: LitecoinWallet(
        seed: mnemonic,
        passphrase: passphrase,
        walletName: p.basename(walletPath),
      ),
    );
  }
}
