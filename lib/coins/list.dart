import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/monero/coin.dart';

const moneroEnabled = bool.fromEnvironment("COIN_MONERO", defaultValue: true);

// This needs to be a global variable, I'm hoping for it to be tree-shaken, and save us some time
// on generating imports dynamically.

final List<Coin> walletCoins = [
  if (moneroEnabled) Monero(),
];
