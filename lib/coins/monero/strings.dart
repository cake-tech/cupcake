import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/gen/assets.gen.dart';

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
  SvgGenImage get svg => Assets.coins.xmr;
}
