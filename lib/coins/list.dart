import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/monero.dart';

const moneroEnabled = bool.fromEnvironment("COIN_MONERO", defaultValue: true);

List<Coin> get walletCoins {
  return [if (moneroEnabled) Monero()];
}
