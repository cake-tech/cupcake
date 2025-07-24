import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'string_form_element.g.dart';

class StringFormElement = StringFormElementBase with _$StringFormElement;

abstract class StringFormElementBase extends FormElement with Store {
  StringFormElementBase(
    this.label, {
    final String initialText = "",
    this.password = false,
    required this.validator,
    this.isExtra = false,
    this.showIf,
    this.randomNameGenerator = false,
    required final Future<void> Function(Object e) errorHandler,
    required this.canPaste,
  })  : ctrl = TextEditingController(text: initialText),
        _errorHandler = errorHandler,
        visibility = !password;

  bool Function()? showIf;
  TextEditingController ctrl;
  bool password;
  @override
  String label;

  @observable
  bool visibility;

  @computed
  @override
  Future<String> get value => Future.value(ctrl.text);

  @override
  @observable
  bool isExtra;

  final bool randomNameGenerator;

  final bool canPaste;

  @computed
  @override
  bool get isOk => validator(ctrl.text) == null;

  String? Function(String? input) validator;

  final Future<void> Function(Object e) _errorHandler;
  @override
  Future<void> errorHandler(final Object e) => _errorHandler(e);
}
