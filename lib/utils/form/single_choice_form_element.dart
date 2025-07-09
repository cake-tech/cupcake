import 'package:cupcake/utils/form/abstract_form_element.dart';

class SingleChoiceFormElement extends FormElement {
  SingleChoiceFormElement({
    required this.title,
    required this.elements,
    required final Future<void> Function(Object e) errorHandler,
    this.isExtra = false,
  }) : _errorHandler = errorHandler;
  String title;
  List<String> elements;

  int currentSelection = 0;

  @override
  bool isExtra;

  @override
  Future<String> get value => Future.value(valueSync);
  String get valueSync => elements[currentSelection];

  @override
  bool get isOk => true;

  final Future<void> Function(Object e) _errorHandler;
  @override
  Future<void> errorHandler(final Object e) => _errorHandler(e);

  @override
  String get label => valueSync;
}
