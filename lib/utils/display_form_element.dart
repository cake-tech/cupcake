import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';

bool displayPinFormElement(final List<FormElement> formElements) {
  if (formElements.isEmpty) return false;
  return (formElements.isNotEmpty &&
          (formElements.first is PinFormElement &&
              (formElements.first as PinFormElement).showNumboard) &&
          !(formElements[0] as PinFormElement).isConfirmed) ||
      formElements.length >= 2 &&
          (formElements[1] is PinFormElement && (formElements[1] as PinFormElement).showNumboard) &&
          !(formElements[1] as PinFormElement).isConfirmed;
}
