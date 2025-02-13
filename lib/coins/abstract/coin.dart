import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';

enum Coins { monero, unknown }

abstract class Coin {
  Coins get type => Coins.unknown;

  CoinStrings get strings;

  bool get isEnabled;

  Future<List<CoinWalletInfo>> get coinWallets;

  bool isSeedSomewhatLegit(final String seed);

  Future<CoinWallet> openWallet(final CoinWalletInfo walletInfo, {required final String password});

  WalletCreation creationMethod(final AppLocalizations L);

  String getPathForWallet(final String walletName);
}
