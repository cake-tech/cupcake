import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/zcash/utils.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:bip39/bip39.dart' as bip39;

class CreateZcashWalletCreationMethod extends CreationMethod {
  CreateZcashWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seedOffsetOrEncryption,
  });
  final AppLocalizations L;

  final String walletPath;
  final String walletPassword;
  final String seedOffsetOrEncryption;

  @override
  Future<CreationOutcome> create() async {
    final mnemonic = bip39.generateMnemonic(strength: 128);

    final u = await ZcashUtils.createNewAccount(
      walletName: p.basename(walletPath),
      seed: mnemonic,
      passphrase: seedOffsetOrEncryption,
      password: walletPassword,
    );

    await u.init();

    return CreationOutcome(
      method: CreateMethod.create,
      success: true,
      wallet: u.wallet,
    );
  }
}
