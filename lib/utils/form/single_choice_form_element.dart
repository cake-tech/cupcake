import 'package:cupcake/utils/form/abstract_form_element.dart';

class SingleChoiceFormElement extends FormElement {
  SingleChoiceFormElement({
    required this.title,
    required this.elements,
    required this.errorHandler,
    this.isExtra = false,
  });
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

  @override
  Future<void> Function(Object e) errorHandler;

  @override
  String get label => valueSync;

  @override
  Future<void> clear() async {
    currentSelection = 0;
  }
}
