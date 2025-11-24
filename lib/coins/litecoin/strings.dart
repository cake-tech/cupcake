import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/gen/assets.gen.dart';

class LitecoinStrings implements CoinStrings {
  @override
  String get nameLowercase => "litecoin";
  @override
  String get nameCapitalized => "Litecoin";
  @override
  String get nameUppercase => "LITECOIN";
  @override
  String get symbolLowercase => "ltc";
  @override
  String get symbolUppercase => "LTC";
  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";

  @override
  SvgGenImage get svg => Assets.coins.ltc;
}
