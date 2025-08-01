import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/gen/assets.gen.dart';

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
  SvgGenImage get svg => Assets.coins.btc;
}
