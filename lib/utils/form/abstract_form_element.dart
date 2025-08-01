abstract class FormElement {
  bool get isOk => true;
  String get label;
  Future<String> get value;
  bool get isExtra;
  Future<void> Function(Object e) errorHandler = (final Object e) async {
    print("unhandled error");
  };
}
