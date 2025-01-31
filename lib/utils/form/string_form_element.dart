import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/default_validator.dart';
import 'package:flutter/cupertino.dart';

class StringFormElement extends FormElement {
  StringFormElement(
    this.label, {
    String initialText = "",
    this.password = false,
    this.validator = defaultFormValidator,
    this.isExtra = false,
    this.showIf,
    this.randomNameGenerator = false,
  }) : ctrl = TextEditingController(text: initialText);

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
}
