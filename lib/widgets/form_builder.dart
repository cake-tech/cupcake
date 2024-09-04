import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:flutter/material.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({super.key, required this.formElements});

  final List<FormElement> formElements;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.formElements.map((e) {
        if (e is StringFormElement) {
          return TextFormField(
            controller: e.ctrl,
            obscureText: e.password,
            enableSuggestions: !e.password,
            autocorrect: !e.password,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error, width: 0.0),
              ),
              hintText: e.label,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: e.validator,
            onChanged: (_) {
              setState(() {});
            },
          );
        }
        return Text("unknown form element: $e");
      }).toList(),
    );
  }
}
