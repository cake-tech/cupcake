abstract class FormElement {
  bool get isOk => true;
  String get label => "";
  Future<String> get value => throw UnimplementedError();
}
