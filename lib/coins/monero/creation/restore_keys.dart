import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:monero/src/wallet2.dart';

class RestoreFromKeysMoneroWalletCreationMethod extends CreationMethod {
  RestoreFromKeysMoneroWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.walletAddress,
    required this.secretSpendKey,
    required this.secretViewKey,
    required this.restoreHeight,
  });

  final AppLocalizations L;
  final String walletPath;
  final String walletPassword;
  final String walletAddress;
  final String secretSpendKey;
  final String secretViewKey;
  final int restoreHeight;

  @override
  Future<CreationOutcome> create() async {
    Wallet2Wallet newWptr;
    if (secretViewKey.isNotEmpty) {
      newWptr = Monero.wm.createWalletFromKeys(
        path: walletPath,
        password: walletPassword,
        restoreHeight: restoreHeight,
        addressString: walletAddress,
        viewKeyString: secretViewKey,
        spendKeyString: secretSpendKey,
      );
    } else {
      newWptr = Monero.wm.createDeterministicWalletFromSpendKey(
        path: walletPath,
        password: walletPassword,
        language: "English",
        spendKeyString: secretSpendKey,
        newWallet: true,
        restoreHeight: restoreHeight,
      );
    }
    int status = newWptr.status();
    if (status != 0) {
      // Fallback to createDeterministicWallet in case when createWalletFromKeys didn't work.
      newWptr = Monero.wm.createDeterministicWalletFromSpendKey(
        path: walletPath,
        password: walletPassword,
        language: "English",
        spendKeyString: secretSpendKey,
        newWallet: true,
        restoreHeight: restoreHeight,
      );
      status = newWptr.status();
    }

    if (status != 0) {
      final error = newWptr.errorString();
      return CreationOutcome(
        method: CreateMethod.restore,
        success: false,
        message: error,
      );
    }
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
