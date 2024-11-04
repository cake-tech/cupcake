import 'package:cupcake/utils/alert.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/main.dart';
import 'package:flutter/material.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({
    super.key,
    required this.formElements,
    required this.scaffoldContext,
    this.rebuild,
    required this.isPinSet,
    required this.showExtra,
  });

  final List<FormElement> formElements;
  final BuildContext scaffoldContext;
  final void Function(bool isPinSet)? rebuild;
  final bool isPinSet;
  final bool showExtra;
  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  void _rebuild() {
    setState(() {});
  }

  void _pinSet(bool val) {
    widget.rebuild?.call(val);
    _rebuild();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.formElements.isNotEmpty &&
            (widget.formElements.first is PinFormElement &&
                (widget.formElements.first as PinFormElement).showNumboard) &&
            !(widget.formElements[0] as PinFormElement).isConfirmed) ||
        widget.formElements.length >= 2 &&
            (widget.formElements[1] is PinFormElement &&
                (widget.formElements[1] as PinFormElement).showNumboard) &&
            !(widget.formElements[1] as PinFormElement).isConfirmed) {
      var e = widget.formElements.first as PinFormElement;
      int i = 0;
      int count = 0;
      if (widget.formElements.length >= 2 &&
          (widget.formElements[1] is PinFormElement)) {
        count++;
      }
      if (e.isConfirmed) {
        i++;
        e = widget.formElements[1] as PinFormElement;
      }
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
              nextPage: () async {
                final b = await callThrowable(context, () async {
                  await e.onConfirmInternal(context);
                }, "Secure storage communication");
                if (b == false) return;
                if (!context.mounted) return;
                _pinSet(count == i);
                e.onConfirm?.call(context);
              },
              showComma: false,
            ),
          const SizedBox(height: 128),
        ],
      );
    }
    final showExtra = widget.showExtra;
    final List<Widget> children = [];
    for (final e in widget.formElements) {
      if (e is StringFormElement) {
        if (e.showIf?.call() == false) continue;
        if (e.isExtra && !showExtra) {
          // If we return Container() some stuff happens on flutter render cache
          // and it doesn't render properly.
          continue;
        }
        children.add(
          Padding(
            padding:
                const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
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
          ),
        );
        continue;
      } else if (e is PinFormElement) {
        if (e.showNumboard) continue;
        children.add(
          Padding(
            padding:
                const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
            child: TextFormField(
              controller: e.ctrl,
              obscureText: true,
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
          ),
        );
        continue;
      } else if (e is SingleChoiceFormElement) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: LongPrimaryButton(
              text: e.valueSync,
              icon: null,
              onPressed: () => _changeSingleChoice(context, e),
              padding: EdgeInsets.zero,
            ),
          ),
        );
        continue;
      }
      children.add(
        Text("unknown form element: $e"),
      );
    }
    print("len: ${children.length}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Future<void> _changeSingleChoice(
      BuildContext context, SingleChoiceFormElement e) async {
    await showAlertWidgetMinimal(
      context: context,
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
