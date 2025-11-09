import 'dart:io';

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:bip39/bip39.dart' as bip39;

class CreateLitecoinWalletCreationMethod extends CreationMethod {
  CreateLitecoinWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.passphrase,
    required this.passphraseConfirm,
  });
  final coin = Litecoin();
  final AppLocalizations L;

  final String walletPath;
  final String walletPassword;
  final String passphrase;
  final String passphraseConfirm;

  @override
  Future<CreationOutcome> create() async {
    if (passphrase != passphraseConfirm) {
      throw Exception("Passphrase doesn't match");
    }
    // ignore: deprecated_member_use
    final mnemonic = bip39.generateMnemonic(strength: 128);

    final keys = "${Litecoin().getPathForWallet(p.basename(walletPath))}.keys";
    final keysEncrypted =
        DefaultEncryption().encryptString("$mnemonic:$passphrase", walletPassword);
    File(keys).writeAsBytesSync(keysEncrypted);

    return CreationOutcome(
      method: CreateMethod.create,
      success: true,
      wallet: LitecoinWallet(
        seed: mnemonic,
        passphrase: passphrase,
        walletName: p.basename(walletPath),
      ),
    );
  }
}
