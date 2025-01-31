import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/monero/coin.dart';

const moneroEnabled = bool.fromEnvironment("COIN_MONERO", defaultValue: true);

List<Coin> get walletCoins {
  return [
    if (moneroEnabled) Monero(),
  ];
}
