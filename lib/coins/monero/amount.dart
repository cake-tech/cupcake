import 'package:cupcake/coins/abstract/amount.dart';
import 'package:monero/monero.dart' as monero;

class MoneroAmount implements Amount {
  MoneroAmount(this.amount);
  @override
  final int amount;

  @override
  // ignore: deprecated_member_use
  String toString() => monero.Wallet_displayAmount(amount);
}
