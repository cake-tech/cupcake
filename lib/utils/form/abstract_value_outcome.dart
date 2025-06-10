abstract class ValueOutcome {
  Future<void> encode(final String input);
  Future<String> decode(final String output);

  String get uniqueId => throw UnimplementedError();
}
