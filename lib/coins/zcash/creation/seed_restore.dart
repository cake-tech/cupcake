import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/zcash/utils.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:bip39/bip39.dart' as bip39;

class SeedRestoreZcashWalletCreationMethod extends CreationMethod {
  SeedRestoreZcashWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seed,
    required this.seedOffsetOrEncryption,
  });
  final AppLocalizations L;

  final String walletPath;
  final String walletPassword;
  final String seed;
  final String seedOffsetOrEncryption;

  @override
  Future<CreationOutcome> create() async {
    if (!bip39.validateMnemonic(seed)) {
      throw Exception("Invalid bip39 mnemonic");
    }

    final u = await ZcashUtils.createNewAccount(
      walletName: p.basename(walletPath),
      seed: seed,
      passphrase: seedOffsetOrEncryption,
      password: walletPassword,
    );

    await u.init();

    return CreationOutcome(
      method: CreateMethod.restore,
      success: true,
      wallet: u.wallet,
    );
  }
}
