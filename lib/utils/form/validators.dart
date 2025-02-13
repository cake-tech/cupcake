import 'package:cupcake/l10n/app_localizations.dart';

String? Function(String? input) doNothingValidator(final AppLocalizations L) {
  return (final _) => null;
}

String? Function(String? input) nonEmptyValidator(
  final AppLocalizations L, {
  final String? Function(String input)? extra,
}) {
  return (final String? input) {
    if (input == null) return L.warning_input_cannot_be_null;
    if (input == "") return L.warning_input_cannot_be_empty;
    return extra?.call(input);
  };
}
