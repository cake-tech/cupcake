import 'package:flutter/material.dart';

class Address {
  Address(this.label, this.address);
  final AddressLabel label;
  final String address;

  @override
  String toString() {
    return address;
  }
}

abstract class AddressLabel {
  String get label;
  String get extra;
  Widget icon(final Color color);
}

class UnknownLabel implements AddressLabel {
  @override
  String get label => "";

  @override
  String get extra => "";

  @override
  Widget icon(final Color color) => SizedBox.shrink();
}
