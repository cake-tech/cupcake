import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class TransparentAddressLabel implements AddressLabel {
  @override
  String get extra => "Public transactions with no privacy";

  @override
  Widget icon(final Color color) => Assets.icons.addressZecTransparent.svg(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  @override
  String get label => "Transparent";
}

class IronwoodAddressLabel implements AddressLabel {
  @override
  String get extra => "Zero-knowledge privacy";

  @override
  Widget icon(final Color color) => Assets.icons.addressZecIronwood.svg(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  @override
  String get label => "Ironwood";
}

class UnifiedAddressLabel implements AddressLabel {
  @override
  String get extra => "Universal address";

  @override
  Widget icon(final Color color) => Assets.icons.addressZecUnified.svg(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );

  @override
  String get label => "Unified";
}
