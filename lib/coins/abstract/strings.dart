import 'package:flutter_svg/flutter_svg.dart';

abstract class CoinStrings {
  String get nameLowercase;
  String get nameCapitalized;
  String get nameUppercase;
  String get symbolLowercase;
  String get symbolUppercase;
  String get nameFull;

  SvgPicture get svg;
}
