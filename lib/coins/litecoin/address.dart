import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class LitecoinAddress extends Address {
  LitecoinAddress(super.label, super.address);
}

class MwebAddressLabel implements AddressLabel {
  @override
  Widget icon(final Color color) => Assets.icons.addressMweb.svg(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  @override
  String get extra => "Private";

  @override
  String get label => "MWEB";
}

class LTCSegwitAddressLabel implements AddressLabel {
  @override
  Widget icon(final Color color) => Assets.icons.addressLtc.svg(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  @override
  String get extra => "Default";

  @override
  String get label => "SegWit";
}
