import 'package:cupcake/coins/abstract/coin_strings.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoneroStrings implements CoinStrings {
  @override
  String get nameLowercase => "monero";
  @override
  String get nameCapitalized => "Monero";
  @override
  String get nameUppercase => "MONERO";
  @override
  String get symbolLowercase => "xmr";
  @override
  String get symbolUppercase => "XMR";
  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";

  @override
  SvgPicture get svg => Assets.coins.xmr.svg();
}
