import 'package:cupcake/utils/form/abstract_value_outcome.dart';

class PlainValueOutcome implements ValueOutcome {
  @override
  Future<String> decode(final String output) => Future.value(output);

  @override
  Future<void> encode(final String input) => Future.value();

  @override
  String get uniqueId => "undefined";
}
