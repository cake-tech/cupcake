import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/utils/config.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

abstract class CoinWalletInfo {
  String get walletName;

  Coins get type => coin.type;

  Coin get coin;

  void openUI(final BuildContext context);

  Future<bool> checkWalletPassword(final String password);

  bool exists();

  Future<CoinWallet> openWallet(final BuildContext context, {required final String password});

  Map<String, dynamic> toJson() {
    return {
      "typeIndex": type.index,
      if (CupcakeConfig.instance.debug) "typeIndex__debug": type.toString(),
      "walletName": p.basename(walletName),
    };
  }

  static CoinWalletInfo? fromJson(final Map<String, dynamic>? json) {
    if (json == null) return null;
    final type = Coins.values[json["typeIndex"] as int];
    final walletName = (json["walletName"] as String);
    switch (type) {
      case Coins.monero:
        return MoneroWalletInfo(walletName);
      case Coins.unknown:
        throw UnimplementedError("unknown coin");
    }
  }

  Future<void> deleteWallet();

  Future<void> renameWallet(final String newName);
}
