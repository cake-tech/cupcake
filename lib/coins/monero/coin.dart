import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/exception.dart';
import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/monero/cache_keys.dart';
import 'package:cupcake/coins/monero/strings.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/coins/monero/wallet.dart';
import 'package:cupcake/coins/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:monero/monero.dart' as monero;
import 'package:path/path.dart' as p;
import 'package:polyseed/polyseed.dart';

class Monero implements Coin {
  static List<monero.wallet> wPtrList = [];

  @override
  bool get isEnabled {
    try {
      monero.isLibOk();
      return true;
    } catch (e) {
      if (CupcakeConfig.instance.debug) {
        print("monero.dart: isLibOk failed: $e");
        return false;
      }
    }
    return false;
  }

  @override
  CoinStrings get strings => MoneroStrings();

  static final baseDir =
      Directory(p.join(baseStoragePath, MoneroStrings().symbolLowercase));

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    // NOTE: We cannot use findWallets on iOS because for some reason it crashes
    // It works on other operating systems somewhat good. I'm not debugging that
    // right now.s
    // final wallets = monero.WalletManager_findWallets(wmPtr, path: baseDir.path);
    // final status = monero.WalletManager_errorString(wmPtr);
    // if (status != "") {
    //   throw Exception(status);
    // }
    // final retWallets = wallets.map((e) => MoneroWalletInfo(e)).toList();
    // retWallets.removeWhere((element) => element.walletName.trim().isEmpty);
    List<CoinWalletInfo> retWallets = [];
    final list = baseDir.listSync(recursive: true, followLinks: true);
    for (var element in list) {
      if (element.absolute.path.endsWith(".keys")) continue;
      if (!monero.WalletManager_walletExists(wmPtr, element.absolute.path)) {
        continue;
      }
      retWallets.add(MoneroWalletInfo(element.absolute.path));
    }
    return Future.value(retWallets);
  }

  Future<void> createMoneroWallet({
    required ProgressCallback? progressCallback,
    required String walletPath,
    required String walletPassword,
    required String seedOffsetOrEncryption,
  }) async {
    progressCallback?.call(description: "Generating polyseed");
    final newSeed = monero.Wallet_createPolyseed();
    progressCallback?.call(description: "Creating wallet");
    final newWptr = monero.WalletManager_createWalletFromPolyseed(
      wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: newSeed,
      seedOffset: seedOffsetOrEncryption,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      print("error: $error");
      throw CoinException(
        error,
        details: "unable to create wallet, createWalletFromPolyseed failed.",
      );
    }
    monero.Wallet_setCacheAttribute(newWptr,
        key: MoneroCacheKeys.seedOffsetCacheKey, value: seedOffsetOrEncryption);
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    wPtrList.add(newWptr);
    print("wallet created in: $walletPath");
    progressCallback?.call(description: "Wallet created");
    await Future.delayed(Duration.zero);
  }

  Future<void> createMoneroWalletPolyseed({
    required ProgressCallback? progressCallback,
    required String walletPath,
    required String walletPassword,
    required String seed,
    required String seedOffsetOrEncryption,
  }) async {
    progressCallback?.call(description: "Creating wallet");
    final lang = PolyseedLang.getByPhrase(seed);
    const coin = PolyseedCoin.POLYSEED_MONERO;
    final dartPolyseed = Polyseed.decode(seed, lang, coin);
    var offset = seedOffsetOrEncryption;
    if (dartPolyseed.isEncrypted) {
      if (seedOffsetOrEncryption.isEmpty) {
        throw CoinException("seed offset is empty, but polyseed is encrypted");
      }
      dartPolyseed.crypt(seedOffsetOrEncryption);
      seed = dartPolyseed.encode(lang, coin);
      offset = "";
    }
    final newWptr = monero.WalletManager_createWalletFromPolyseed(
      wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: seed,
      seedOffset: offset,
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    wPtrList.add(newWptr);
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      throw CoinException(
        error,
        details: "unable to create wallet, createWalletFromPolyseed failed.",
      );
    }
    monero.Wallet_setCacheAttribute(newWptr,
        key: MoneroCacheKeys.seedOffsetCacheKey, value: seedOffsetOrEncryption);
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    progressCallback?.call(description: "Wallet created");
  }

  Future<void> createMoneroWalletSeed({
    required ProgressCallback? progressCallback,
    required String walletPath,
    required String walletPassword,
    required String seed,
    required String seedOffsetOrEncryption,
  }) async {
    progressCallback?.call(description: "Creating wallet");
    final newWptr = monero.WalletManager_recoveryWallet(
      wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: seed,
      seedOffset: seedOffsetOrEncryption,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    wPtrList.add(newWptr);
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      throw CoinException(
        error,
        details: "unable to create wallet, recoveryWallet failed.",
      );
    }
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    progressCallback?.call(description: "Wallet created");
  }

  Future<void> createMoneroWalletKeys({
    required ProgressCallback? progressCallback,
    required String walletPath,
    required String walletPassword,
    required String walletAddress,
    required String secretSpendKey,
    required String secretViewKey,
    required int restoreHeight,
  }) async {
    progressCallback?.call(description: "Creating wallet");
    final newWptr = monero.WalletManager_createWalletFromKeys(wmPtr,
        path: walletPath,
        password: walletPassword,
        restoreHeight: restoreHeight,
        addressString: walletAddress,
        viewKeyString: secretViewKey,
        spendKeyString: secretSpendKey);
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      throw CoinException(
        error,
        details: "unable to create wallet, recoveryWallet failed.",
      );
    }
    monero.Wallet_store(newWptr);
    monero.Wallet_store(newWptr);
    progressCallback?.call(description: "Wallet created");
  }

  @override
  Future<CoinWallet> createNewWallet(
    String walletName,
    String walletPassword, {
    ProgressCallback? progressCallback,
    required bool? createWallet,
    required String? seed,
    required int? restoreHeight,
    required String? primaryAddress,
    required String? viewKey,
    required String? spendKey,
    required String? seedOffsetOrEncryption,
  }) async {
    progressCallback?.call(
        title: "Creating new wallet", description: "Initializing...");
    final baseDir = Directory(p.join(baseStoragePath, strings.symbolLowercase));
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final String walletPath = p.join(baseDir.path, walletName);

    if (createWallet == true) {
      // new wallet
      // new wallet polyseed offset
      // new wallet polyseed encrypt
      // new wallet legacy offset
      await createMoneroWallet(
        progressCallback: progressCallback,
        walletPath: walletPath,
        walletPassword: walletPassword,
        seedOffsetOrEncryption: seedOffsetOrEncryption ?? "",
      );
    } else if (createWallet == false &&
        (seed ?? "").trim().split(" ").length == 16) {
      await createMoneroWalletPolyseed(
        progressCallback: progressCallback,
        walletPath: walletPath,
        walletPassword: walletPassword,
        seed: seed!,
        seedOffsetOrEncryption: seedOffsetOrEncryption ?? "",
      );
      // polyseed
      // polyseed encrypted
      // polyseed offset
    } else if (createWallet == false &&
        (seed ?? "").trim().split(" ").length == 25) {
      await createMoneroWalletSeed(
          progressCallback: progressCallback,
          walletPath: walletPath,
          walletPassword: walletPassword,
          seed: seed!,
          seedOffsetOrEncryption: seedOffsetOrEncryption ?? "");
      // legacy seed
      // legacy seed offset
    } else if (createWallet == false && spendKey != "") {
      // keys deterministic
      // keys non-deterministic
      await createMoneroWalletKeys(
        progressCallback: progressCallback,
        walletPath: walletPath,
        walletPassword: walletPassword,
        walletAddress: primaryAddress!,
        secretSpendKey: spendKey!,
        secretViewKey: viewKey!,
        restoreHeight: restoreHeight!,
      );
    } else {
      throw Exception("Unknown form used to create wallet");
    }

    return openWallet(MoneroWalletInfo(walletPath), password: walletPassword);
  }

  @override
  Future<CoinWallet> openWallet(CoinWalletInfo walletInfo,
      {required String password}) async {
    for (var wptr in wPtrList) {
      monero.WalletManager_closeWallet(wmPtr, wptr, true);
    }
    wPtrList.clear();
    final walletExist =
        monero.WalletManager_walletExists(wmPtr, walletInfo.walletName);
    if (!walletExist) {
      throw Exception("Given wallet doesn't exist (${walletInfo.walletName})");
    }
    final wptr = monero.WalletManager_openWallet(wmPtr,
        path: walletInfo.walletName, password: password);
    final status = monero.Wallet_status(wptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(wptr);
      throw Exception(error);
    }
    CupcakeConfig.instance.lastWallet = walletInfo;
    CupcakeConfig.instance.save();
    return MoneroWallet(wptr);
  }

  @override
  Coins get type => Coins.monero;

  // monero.dart stuff
  static monero.WalletManager wmPtr =
      monero.WalletManagerFactory_getWalletManager();
}
