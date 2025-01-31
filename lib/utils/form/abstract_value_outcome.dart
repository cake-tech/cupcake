abstract class ValueOutcome {
  Future<void> encode(String input);
  Future<String> decode(String output);

  String get uniqueId => throw UnimplementedError();
}
