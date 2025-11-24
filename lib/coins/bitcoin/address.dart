import 'package:cupcake/coins/abstract/address.dart';
import 'package:flutter/material.dart';

class BitcoinAddress extends Address {
  BitcoinAddress(super.label, super.address);
}

class SegwitAddress implements AddressLabel {
  @override
  Widget icon(final Color color) => Icon(
        Icons.currency_bitcoin,
        color: color,
      );

  @override
  String get extra => "";

  @override
  String get label => "SegWit";
}
