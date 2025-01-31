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
  });

  Future<CoinWallet> openWallet(CoinWalletInfo walletInfo,
      {required String password});
}
