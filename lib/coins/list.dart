import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/coins/monero/coin.dart';

const moneroEnabled = bool.fromEnvironment("COIN_MONERO", defaultValue: true);
const bitcoinEnabled = bool.fromEnvironment("COIN_BITCOIN", defaultValue: true);
const litecoinEnabled = bool.fromEnvironment("COIN_LITECOIN", defaultValue: true);

// This needs to be a global variable, I'm hoping for it to be tree-shaken, and save us some time
// on generating imports dynamically.

final List<Coin> walletCoins = [
  if (moneroEnabled) Monero(),
  if (bitcoinEnabled) Bitcoin(),
  if (litecoinEnabled) Litecoin(),
];
