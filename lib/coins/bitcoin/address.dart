import 'package:cupcake/coins/abstract/address.dart';

class BitcoinAddress implements Address {
  BitcoinAddress(this.address);

  @override
  final String address;
}
