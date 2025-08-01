import 'dart:async';

import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/alerts/widget_minimal.dart';
import 'package:cupcake/utils/display_form_element.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/single_choice_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/random_name.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/widgets/base_text_form_field.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class FormBuilder extends StatelessWidget {
  FormBuilder({super.key, required this.viewModel, required this.showExtra});

  late AppLocalizations L;
  late ThemeData T;

  final FormBuilderViewModel viewModel;

  final bool showExtra;

  String? lastSuggestedTitle = DateTime.now().toIso8601String();
  void _onLabelChange(final String? suggestedTitle) {
    if (suggestedTitle == lastSuggestedTitle) return;
    lastSuggestedTitle = suggestedTitle;
    viewModel.onLabelChange(suggestedTitle);
  }

  @override
  Widget build(final BuildContext context) {
    L = AppLocalizations.of(context)!;
    T = Theme.of(context);
    viewModel.register(context);
    return Observer(
      builder: (final context) => _build(context),
    );
  }

  final pinFormTextInputFocusNode = FocusNode();

  Widget _build(final BuildContext context) {
    if (displayPinFormElement(viewModel.formElements)) {
      var e = viewModel.formElements.first as PinFormElement;
      int i = 0;
      int count = 0;
      if (viewModel.formElements.length >= 2 && (viewModel.formElements[1] is PinFormElement)) {
        count++;
      }
      if (e.isConfirmed) {
        i++;
        e = viewModel.formElements[1] as PinFormElement;
      }
      _onLabelChange(e.label);
      Future<void> nextPageCallback() async {
        try {
          await e.onConfirmInternal(context);
          if (!context.mounted) return;
          await e.onConfirm?.call();
          viewModel.isPinSet = (count == i);
        } catch (err) {
          viewModel.isPinSet = false;
          await e.errorHandler(err);
          return;
        }
      }

      // don't worry about this, it just simulates user input and clicks "next" button.
      // by reading secure storage element.
      // This way just "bypassing" pin screen won't help, you need to actually enter the pin.
      // be that from secure storage or by actually entering it.
      unawaited(e.loadSecureStorageValue(nextPageCallback));
      // We can probably move this somewhere else, but I like it here.
      void $nextPageCallback() {
        if (e.enableBiometric) {
          viewModel.enableSystemAuth(e, nextPageCallback);
        } else {
          nextPageCallback();
        }
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 52),
          Text(
            count == i && i != 0
                ? L.reenter_your_pin
                : count == 0
                    ? L.enter_your_pin
                    : L.create_your_pin,
            style: T.textTheme.bodyLarge?.copyWith(fontSize: 20),
          ),
          if (viewModel.isPinInput)
            TextFormField(
              focusNode: pinFormTextInputFocusNode,
              controller: e.ctrl,
              obscureText: e.password,
              enableSuggestions: !e.password,
              autocorrect: !e.password,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (final _) {
                e.onChanged?.call();
              },
              style: const TextStyle(
                fontSize: 64,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: BaseTextFormField(
                controller: e.ctrl,
                obscureText: e.password,
                enableSuggestions: !e.password,
                autocorrect: !e.password,
              ),
            ),
          const SizedBox(height: 16),
          if (count == i && i == 0)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: T.colorScheme.surfaceContainer,
                foregroundColor: T.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                viewModel.isPinInput = !viewModel.isPinInput;
              },
              child: Text(viewModel.isPinInput ? L.switch_to_password : L.switch_to_pin),
            ),
          const SizedBox(height: 32),
          if (viewModel.isPinInput)
            NumericalKeyboard(
              ctrl: e.ctrl,
              showConfirm: () => e.isOk,
              nextPage: $nextPageCallback,
              onConfirmLongPress: null,
              showComma: false,
            ),
          const Spacer(),
          if (!viewModel.isPinInput)
            SafeArea(
              bottom: true,
              top: false,
              child: LongPrimaryButton(
                onPressed: $nextPageCallback,
                padding: EdgeInsets.zero,
                text: L.continue_,
              ),
            ),
          const SizedBox(height: 8),
        ],
      );
    }
    _onLabelChange(null);
    final List<Widget> children = [];
    for (final e in viewModel.formElements) {
      if (e.isExtra && !showExtra) {
        // If we return Container() some stuff happens on flutter render cache
        // and it doesn't render properly.
        continue;
      }
      if (e is StringFormElement) {
        if (e.showIf?.call() == false) continue;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
            child: BaseTextFormField(
              controller: e.ctrl,
              obscureText: !e.visibility,
              enableSuggestions: !e.password,
              autocorrect: !e.password,
              hintText: e.label,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: e.validator,
              onChanged: (final _) {},
              suffixIcon: e.password
                  ? e.visibility
                      ? Icons.visibility_off
                      : Icons.visibility
                  : e.randomNameGenerator
                      ? Icons.refresh
                      : e.canPaste
                          ? Icons.paste
                          : null,
              suffixIconOnPressed: e.password
                  ? () => e.visibility = !e.visibility
                  : e.randomNameGenerator
                      ? () => randomName(e.ctrl)
                      : e.canPaste
                          ? () async {
                              final data = await Clipboard.getData(Clipboard.kTextPlain);
                              if (data != null) {
                                e.ctrl.text = data.text ?? '';
                              }
                            }
                          : null,
            ),
          ),
        );
        continue;
      } else if (e is PinFormElement) {
        if (e.showNumboard) continue;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
            child: BaseTextFormField(
              controller: e.ctrl,
              obscureText: true,
              enableSuggestions: !e.password,
              autocorrect: !e.password,
              hintText: e.label,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: e.validator,
              onChanged: (final _) {},
            ),
          ),
        );
        continue;
      } else if (e is SingleChoiceFormElement) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12, right: 12),
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
        Text(L.error_unknown_form_element(e)),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Future<void> _changeSingleChoice(
    final BuildContext context,
    final SingleChoiceFormElement e,
  ) async {
    await showAlertWidgetMinimal(
      context: context,
      body: List.generate(
        e.elements.length,
        (final index) {
          return InkWell(
            child: LongPrimaryButton(
              text: e.elements[index],
              icon: null,
              onPressed: () {
                e.currentSelection = index;
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
