import 'package:cupcake/l10n/app_localizations.dart';

extension NumOrdinal on int {
  String ordinal(final AppLocalizations L) {
    return OrdinalHelper._getOrdinalNumber(L, this);
  }
}

class OrdinalHelper {
  static String _getOrdinalNumber(final AppLocalizations L, final int number) {
    final locale = L.localeName;

    final String suffix = _getOrdinalSuffix(number, locale);
    return "$number$suffix";
  }

  static String _getOrdinalSuffix(final int number, final String locale) => switch (locale) {
        'en' => _getEnglishOrdinalSuffix(number),
        'pl' => _getPolishOrdinalSuffix(number),
        _ => _getEnglishOrdinalSuffix(number),
      };

  static String _getEnglishOrdinalSuffix(final int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    return switch (number % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  static String _getPolishOrdinalSuffix(final int number) {
    if (number >= 11 && number <= 13) {
      return '-ty';
    }
    return switch (number % 10) {
      1 => '-szy',
      2 => '-gi',
      3 => '-ci',
      _ => '-ty',
    };
  }
}
