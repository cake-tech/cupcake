abstract class FormElement {
  bool get isOk => true;
  String get label;
  Future<String> get value;
  bool get isExtra;
  Future<void> errorHandler(final Object e);
}
