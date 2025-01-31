abstract class FormElement {
  bool get isOk => true;
  String get label => throw UnimplementedError();
  Future<String> get value => throw UnimplementedError();
}
