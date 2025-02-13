import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:flutter/cupertino.dart';

class StringFormElement extends FormElement {
  StringFormElement(
    this.label, {
    final String initialText = "",
    this.password = false,
    required this.validator,
    this.isExtra = false,
    this.showIf,
    this.randomNameGenerator = false,
    required final Future<void> Function(Object e) errorHandler,
  })  : ctrl = TextEditingController(text: initialText),
        _errorHandler = errorHandler;

  bool Function()? showIf;
  TextEditingController ctrl;
  bool password;
  @override
  String label;
  @override
  Future<String> get value => Future.value(ctrl.text);

  bool isExtra;
  bool randomNameGenerator;

  @override
  bool get isOk => validator(ctrl.text) == null;

  String? Function(String? input) validator;

  final Future<void> Function(Object e) _errorHandler;
  @override
  Future<void> errorHandler(final Object e) => _errorHandler(e);
}
