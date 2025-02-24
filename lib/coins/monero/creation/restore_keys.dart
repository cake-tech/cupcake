import 'dart:ffi';

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:monero/monero.dart' as monero;

class RestoreFromKeysMoneroWalletCreationMethod extends CreationMethod {
  RestoreFromKeysMoneroWalletCreationMethod(
    this.L, {
    required this.walletPath,
    required this.walletPassword,
    required this.walletAddress,
    required this.secretSpendKey,
    required this.secretViewKey,
    required this.restoreHeight,
    this.progressCallback,
  });

  final AppLocalizations L;
  final ProgressCallback? progressCallback;
  final String walletPath;
  final String walletPassword;
  final String walletAddress;
  final String secretSpendKey;
  final String secretViewKey;
  final int restoreHeight;

  @override
  Future<CreationOutcome> create() async {
    progressCallback?.call(description: L.creating_wallet);
    Pointer<Void> newWptr;
    if (secretViewKey.isNotEmpty) {
      newWptr = monero.WalletManager_createWalletFromKeys(
        Monero.wmPtr,
        path: walletPath,
        password: walletPassword,
        restoreHeight: restoreHeight,
        addressString: walletAddress,
        viewKeyString: secretViewKey,
        spendKeyString: secretSpendKey,
      );
    } else {
      newWptr = monero.WalletManager_createDeterministicWalletFromSpendKey(
        Monero.wmPtr,
        path: walletPath,
        password: walletPassword,
        language: "English",
        spendKeyString: secretSpendKey,
        newWallet: true,
        restoreHeight: restoreHeight,
      );
    }
    progressCallback?.call(description: L.checking_status);
    int status = monero.Wallet_status(newWptr);
    if (status != 0) {
      // Fallback to createDeterministicWallet in case when createWalletFromKeys didn't work.
      newWptr = monero.WalletManager_createDeterministicWalletFromSpendKey(
        Monero.wmPtr,
        path: walletPath,
        password: walletPassword,
        language: "English",
        spendKeyString: secretSpendKey,
        newWallet: true,
        restoreHeight: restoreHeight,
      );
      status = monero.Wallet_status(newWptr);
    }

    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      return CreationOutcome(
        method: CreateMethod.restore,
        success: false,
        message: error,
      );
    }
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    progressCallback?.call(description: L.wallet_created);
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
