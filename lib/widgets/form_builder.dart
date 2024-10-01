import 'package:cup_cake/utils/alert.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/views/initial_setup_screen.dart';
import 'package:cup_cake/views/widgets/numerical_keyboard/main.dart';
import 'package:flutter/material.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder(
      {super.key,
      required this.formElements,
      required this.scaffoldContext,
      this.rebuild,
      required this.isPinSet});

  final List<FormElement> formElements;
  final BuildContext scaffoldContext;
  final void Function(bool isPinSet)? rebuild;
  final bool isPinSet;
  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  void _rebuild() {
    setState(() {});
  }

  void _pinSet() {
    widget.rebuild?.call(true);
    _rebuild();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formElements.isNotEmpty &&
        widget.formElements.first is PinFormElement &&
        !widget.isPinSet) {
      final e = widget.formElements.first as PinFormElement;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: e.ctrl,
            obscureText: e.password,
            enableSuggestions: !e.password,
            autocorrect: !e.password,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (_) {
              e.onChanged?.call(context);
            },
            style: const TextStyle(
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 32),
          if (MediaQuery.of(widget.scaffoldContext).viewInsets.bottom == 0)
            NumericalKeyboard(
              ctrl: e.ctrl,
              rebuild: _rebuild,
              showConfirm: () => e.isOk,
              nextPage: () {
                _pinSet();
                e.onConfirm?.call(context);
              },
              showComma: false,
            ),
          const SizedBox(height: 128),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.formElements.map((e) {
        if (e is StringFormElement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextFormField(
              controller: e.ctrl,
              obscureText: e.password,
              enableSuggestions: !e.password,
              autocorrect: !e.password,
              decoration: InputDecoration(
                border: null,
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 0.0,
                  ),
                ),
                hintText: e.label,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: e.validator,
              onChanged: (_) {
                _rebuild();
              },
              textAlign: TextAlign.center,
            ),
          );
        } else if (e is PinFormElement) {
          return Container();
        } else if (e is SingleChoiceFormElement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: LongPrimaryButton(
              text: e.value,
              icon: null,
              onPressed: () => _changeSingleChoice(context, e),
              padding: EdgeInsets.zero,
            ),
          );
        }
        return Text("unknown form element: $e");
      }).toList(),
    );
  }

  Future<void> _changeSingleChoice(
      BuildContext context, SingleChoiceFormElement e) async {
    showAlertWidget(
      context: context,
      title: e.title,
      body: List.generate(
        e.elements.length,
        (index) {
          return InkWell(
            child: LongPrimaryButton(
              text: e.elements[index],
              icon: null,
              onPressed: () {
                e.currentSelection = index;
                _rebuild();
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
