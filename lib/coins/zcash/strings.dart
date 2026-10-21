import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/gen/assets.gen.dart';

class ZcashStrings implements CoinStrings {
  @override
  String get nameCapitalized => "Zcash";

  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";

  @override
  String get nameLowercase => "zcash";

  @override
  String get nameUppercase => "ZCASH";

  @override
  SvgGenImage get svg => Assets.coins.zec;

  @override
  String get symbolLowercase => "zec";

  @override
  String get symbolUppercase => "ZEC";
}
