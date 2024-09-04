import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/filesystem.dart';
import 'package:cup_cake/views/open_wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monero/monero.dart' as monero;
import 'package:path/path.dart' as p;

class Monero implements Coin {
  @override
  bool get isEnabled {
    try {
      monero.isLibOk();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("monero.dart: isLibOk failed: $e");
        return false;
      }
    }
    return false;
  }

  @override
  CoinStrings get strings => MoneroStrings();

  @override
  List<CoinWalletInfo> get coinWallets {
    final wallets =
        monero.WalletManager_findWallets(wmPtr, path: baseStoragePath)
            .split(";");
    return wallets.map((e) => MoneroWalletInfo(e)).toList();
  }

  @override
  Future<void> createNewWallet(
    String walletName,
    String walletPassword, {
    ProgressCallback? progressCallback,
  }) async {
    progressCallback?.call(
        title: "Creating new wallet", description: "Initializing...");
    final String walletPath = p.join(baseStoragePath, walletName);
    progressCallback?.call(description: "Generating polyseed");
    final newSeed = monero.Wallet_createPolyseed();
    progressCallback?.call(description: "Creating wallet");
    final newWptr = monero.WalletManager_createWalletFromPolyseed(
      wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: newSeed,
      seedOffset: "",
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      throw CoinException(
        error,
        details: "unable to create wallet, createWalletFromPolyseed failed.",
      );
    }
    progressCallback?.call(description: "Wallet created");
  }

  // monero.dart stuff
  monero.WalletManager wmPtr = monero.WalletManagerFactory_getWalletManager();

  @override
  Coins get type => Coins.monero;
}

class MoneroStrings implements CoinStrings {
  @override
  String get nameLowercase => "monero";
  @override
  String get nameCapitalized => "Monero";
  @override
  String get nameUppercase => "MONERO";
  @override
  String get symbolLowercase => "xmr";
  @override
  String get symbolUppercase => "XMR";
  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";
}

class MoneroWalletInfo implements CoinWalletInfo {
  MoneroWalletInfo(this._walletName);

  @override
  Coin get coin => Monero();

  @override
  String get walletName => _walletName;
  final String _walletName;

  @override
  Coins get type => coin.type;

  @override
  void open(BuildContext context) {
    OpenWallet.pushStatic(context, this);
  }
}
