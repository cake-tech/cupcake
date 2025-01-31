import 'package:cupcake/utils/form/abstract_form_element.dart';

class SingleChoiceFormElement extends FormElement {
  SingleChoiceFormElement({required this.title, required this.elements});
  String title;
  List<String> elements;

  int currentSelection = 0;

  @override
  Future<String> get value => Future.value(valueSync);
  String get valueSync => elements[currentSelection];

  @override
  bool get isOk => true;
}
