import 'dart:io';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/bitcoin/creation/common.dart';
import 'package:cupcake/coins/bitcoin/debug/bdk_tx_test.dart';
import 'package:cupcake/coins/bitcoin/strings.dart';
import 'package:cupcake/coins/bitcoin/wallet.dart';
import 'package:cupcake/coins/bitcoin/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class Bitcoin implements Coin {
  Bitcoin();
  @override
  String get uriScheme => 'bitcoin';

  @override
  bool get isEnabled => true;

  @override
  CoinStrings get strings => BitcoinStrings();

  static final baseDir = Directory(p.join(baseStoragePath, BitcoinStrings().symbolLowercase));

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final List<CoinWalletInfo> retWallets = [];
    final list = baseDir.listSync(recursive: true, followLinks: true);
    for (final element in list) {
      if (!element.absolute.path.endsWith(".keys")) continue;
      retWallets.add(BitcoinWalletInfo(element.absolute.path));
    }
    return Future.value(retWallets);
  }

  @override
  String getPathForWallet(final String walletName) {
    final baseDir = Directory(p.join(baseStoragePath, strings.symbolLowercase));
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    // Prevent user from slipping outside allowed directory
    final String walletPath = p.join(baseDir.path, walletName);
    if (!walletPath.startsWith(baseDir.path)) {
      throw Exception(Coin.L.error_illegal_wallet_name(walletName));
    }
    return walletPath;
  }

  @override
  Future<CoinWallet> openWallet(
    final CoinWalletInfo walletInfo, {
    required final String password,
  }) async {
    final encrypted = File("${walletInfo.walletName}.keys").readAsBytesSync();
    final mnemonic = DefaultEncryption().decryptString(encrypted, password);
    final wallet = await createWalletObject(mnemonic);
    return BitcoinWallet(
      wallet,
      seed: mnemonic,
      walletName: walletInfo.walletName,
    );
  }

  @override
  Coins get type => Coins.bitcoin;

  @override
  bool isSeedSomewhatLegit(final String seed) {
    final length = seed.split(" ").length;
    return [12].contains(length);
  }

  @override
  WalletCreation creationMethod(final AppLocalizations L) => BitcoinWalletCreation(L);

  Future<BDKWalletWrapper> createWalletObject(
    final String mnemonic,
  ) async {
    final List<Wallet> wallets = [];
    final m = await Mnemonic.fromString(mnemonic);
    final descriptorSecretKey = (await DescriptorSecretKey.create(
      network: Network.bitcoin,
      mnemonic: m,
    ));
    final externalDescriptor84 = await Descriptor.newBip84(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.externalChain,
    );
    final internalDescriptor84 = await Descriptor.newBip84(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.internalChain,
    );

    wallets.add(
      await Wallet.create(
        descriptor: externalDescriptor84,
        changeDescriptor: internalDescriptor84,
        network: Network.bitcoin,
        databaseConfig: DatabaseConfig.memory(),
      ),
    );
    final externalDescriptor44 = await Descriptor.newBip44(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.externalChain,
    );
    final internalDescriptor44 = await Descriptor.newBip44(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.internalChain,
    );

    wallets.add(
      await Wallet.create(
        descriptor: externalDescriptor44,
        changeDescriptor: internalDescriptor44,
        network: Network.bitcoin,
        databaseConfig: DatabaseConfig.memory(),
      ),
    );

    final externalDescriptor49 = await Descriptor.newBip49(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.externalChain,
    );
    final internalDescriptor49 = await Descriptor.newBip49(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.internalChain,
    );

    wallets.add(
      await Wallet.create(
        descriptor: externalDescriptor49,
        changeDescriptor: internalDescriptor49,
        network: Network.bitcoin,
        databaseConfig: DatabaseConfig.memory(),
      ),
    );

    final externalDescriptor86 = await Descriptor.newBip86(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.externalChain,
    );
    final internalDescriptor86 = await Descriptor.newBip86(
      secretKey: descriptorSecretKey,
      network: Network.bitcoin,
      keychain: KeychainKind.internalChain,
    );

    wallets.add(
      await Wallet.create(
        descriptor: externalDescriptor86,
        changeDescriptor: internalDescriptor86,
        network: Network.bitcoin,
        databaseConfig: DatabaseConfig.memory(),
      ),
    );

    String xpub =
        (await (descriptorSecretKey.derive(await DerivationPath.create(path: "m/84'/0'/0'"))))
            .toPublic()
            .asString();
    xpub = xpub.substring(xpub.indexOf("]") + 1, xpub.lastIndexOf("/"));

    for (final wallet in wallets) {
      for (var i = 0; i < 1000; i++) {
        wallet.getAddress(addressIndex: AddressIndex.increase());
      }
    }
    return BDKWalletWrapper(
      wallets: wallets,
      mnemonic: m,
      xpub: xpub,
    );
  }

  @override
  Map<String, Function(BuildContext context, CoinWallet wallet)> debugOptions = {
    "BDK PSBT TEST (online)": (final BuildContext context, final CoinWallet wallet) => BDKPSBT(
          wallet: wallet,
        ).push(context),
  };
}
