import 'package:cupcake/coins/abstract/amount.dart';

class BitcoinAmount implements Amount {
  BitcoinAmount(this.amount);
  @override
  final int amount;

  @override
  String toString() => (amount / 1e8).toStringAsFixed(8);
}
