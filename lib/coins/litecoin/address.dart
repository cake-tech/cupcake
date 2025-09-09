import 'package:cupcake/coins/abstract/address.dart';

class LitecoinAddress implements Address {
  LitecoinAddress(this.address);

  @override
  final String address;
}
