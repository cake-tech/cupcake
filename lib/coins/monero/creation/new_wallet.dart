import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/monero/cache_keys.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:monero/monero.dart' as monero;

class CreateMoneroWalletCreationMethod extends CreationMethod {
  CreateMoneroWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seedOffsetOrEncryption,
    this.progressCallback,
  });
  final AppLocalizations L;

  final ProgressCallback? progressCallback;
  final String walletPath;
  final String walletPassword;
  final String seedOffsetOrEncryption;

  @override
  Future<CreationOutcome> create() async {
    progressCallback?.call(description: L.generating_polyseed);
    final newSeed = monero.Wallet_createPolyseed();
    progressCallback?.call(description: L.creating_wallet);
    final newWptr = monero.WalletManager_createWalletFromPolyseed(
      Monero.wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: newSeed,
      seedOffset: seedOffsetOrEncryption,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    progressCallback?.call(description: L.checking_status);
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      return CreationOutcome(
        method: CreateMethod.create,
        success: false,
        message: error,
      );
    }
    monero.Wallet_setCacheAttribute(
      newWptr,
      key: MoneroCacheKeys.seedOffsetCacheKey,
      value: seedOffsetOrEncryption,
    );
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    Monero.wPtrList.add(newWptr);
    progressCallback?.call(description: L.wallet_created);
    final wallet = await Monero().openWallet(
      MoneroWalletInfo(p.basename(walletPath)),
      password: walletPassword,
    );
    return CreationOutcome(
      method: CreateMethod.create,
      success: true,
      wallet: wallet,
    );
  }
}
