import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/monero/cache_keys.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:polyseed/polyseed.dart';

class RestorePolyseedMoneroWalletCreationMethod extends CreationMethod {
  RestorePolyseedMoneroWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.seed,
    required this.seedOffsetOrEncryption,
  });
  final AppLocalizations L;

  final String walletPath;
  final String walletPassword;
  String seed;
  final String seedOffsetOrEncryption;

  @override
  Future<CreationOutcome> create() async {
    final lang = PolyseedLang.getByPhrase(seed);
    const coin = PolyseedCoin.POLYSEED_MONERO;
    final dartPolyseed = Polyseed.decode(seed, lang, coin);
    var offset = seedOffsetOrEncryption;
    if (dartPolyseed.isEncrypted) {
      if (seedOffsetOrEncryption.isEmpty) {
        return CreationOutcome(
          method: CreateMethod.restore,
          success: false,
          message: L.warning_seed_offset_empty_polyseed_encrypted,
        );
      }
      dartPolyseed.crypt(seedOffsetOrEncryption);
      seed = dartPolyseed.encode(lang, coin);
      offset = "";
    }
    final newWptr = Monero.wm.createWalletFromPolyseed(
      path: walletPath,
      password: walletPassword,
      mnemonic: seed,
      seedOffset: offset,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    Monero.wPtrList.add(newWptr);
    final status = newWptr.status();
    if (status != 0) {
      final error = newWptr.errorString();
      return CreationOutcome(
        method: CreateMethod.restore,
        success: false,
        message: error,
      );
    }
    newWptr.setCacheAttribute(
      key: MoneroCacheKeys.seedOffsetCacheKey,
      value: seedOffsetOrEncryption,
    );
    newWptr.store();
    newWptr.store();
    final wallet = await Monero().openWallet(
      MoneroWalletInfo(p.basename(walletPath)),
      password: walletPassword,
    );
    return CreationOutcome(
      method: CreateMethod.restore,
      success: true,
      wallet: wallet,
    );
  }
}
