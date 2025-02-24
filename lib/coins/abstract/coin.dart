import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/types.dart';

enum Coins { monero, unknown }

abstract class Coin {
  Coins get type => Coins.unknown;

  CoinStrings get strings;

  bool get isEnabled;

  Future<List<CoinWalletInfo>> get coinWallets;

  Future<CoinWallet> createNewWallet(
    final String walletName,
    final String walletPassword, {
    final ProgressCallback? progressCallback,
    required final bool? createWallet,
    required final String? seed,
    required final int? restoreHeight,
    required final String? primaryAddress,
    required final String? viewKey,
    required final String? spendKey,
    required final String? seedOffsetOrEncryption,
  });

  bool isSeedSomewhatLegit(final String seed);

  Future<CoinWallet> openWallet(final CoinWalletInfo walletInfo,
      {required final String password});
}
