import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BitcoinStrings implements CoinStrings {
  @override
  String get nameLowercase => "bitcoin";
  @override
  String get nameCapitalized => "Bitcoin";
  @override
  String get nameUppercase => "BITCOIN";
  @override
  String get symbolLowercase => "btc";
  @override
  String get symbolUppercase => "BTC";
  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";

  @override
  SvgPicture get svg => Assets.coins.btc.svg();
}
