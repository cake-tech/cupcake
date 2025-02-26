import 'dart:async';

import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/alerts/widget_minimal.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/single_choice_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/random_name.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_auth/local_auth.dart';

class FormBuilder extends StatelessWidget {
  FormBuilder({super.key, required this.viewModel, required this.showExtra});

  late AppLocalizations L;

  final FormBuilderViewModel viewModel;

  final bool showExtra;

  String? lastSuggestedTitle = DateTime.now().toIso8601String();
  void _onLabelChange(final String? suggestedTitle) {
    if (suggestedTitle == lastSuggestedTitle) return;
    lastSuggestedTitle = suggestedTitle;
    viewModel.onLabelChange(suggestedTitle);
  }

  bool _displayPinFormElement() {
    return (viewModel.formElements.isNotEmpty &&
            (viewModel.formElements.first is PinFormElement &&
                (viewModel.formElements.first as PinFormElement).showNumboard) &&
            !(viewModel.formElements[0] as PinFormElement).isConfirmed) ||
        viewModel.formElements.length >= 2 &&
            (viewModel.formElements[1] is PinFormElement &&
                (viewModel.formElements[1] as PinFormElement).showNumboard) &&
            !(viewModel.formElements[1] as PinFormElement).isConfirmed;
  }

  @override
  Widget build(final BuildContext context) {
    L = AppLocalizations.of(context)!;
    return Observer(
      builder: (final context) => _build(context),
    );
  }

  Widget _build(final BuildContext context) {
    final _ = viewModel.currentPageDoNotUse; // very silly way to force a rebuild
    if (_displayPinFormElement()) {
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
          viewModel.currentPageDoNotUse++;
          viewModel.isPinSet = (count == i);
          await e.onConfirm?.call();
        } catch (err) {
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
            onChanged: (final _) {
              e.onChanged?.call();
            },
            style: const TextStyle(
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 32),
          if (MediaQuery.of(viewModel.scaffoldContext).viewInsets.bottom == 0)
            NumericalKeyboard(
              ctrl: e.ctrl,
              showConfirm: () => e.isOk,
              nextPage: nextPageCallback,
              onConfirmLongPress: () async {
                try {
                  await e.onConfirmInternal(context);
                  final auth = LocalAuthentication();

                  final List<BiometricType> availableBiometrics =
                      await auth.getAvailableBiometrics();
                  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                  final bool canAuthenticate =
                      canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                  if (!canAuthenticate) throw Exception(L.error_no_biometric_authentication);
                  if (!availableBiometrics.contains(BiometricType.fingerprint) &&
                      !availableBiometrics.contains(BiometricType.face) &&
                      !CupcakeConfig.instance.canUseInsecureBiometric) {
                    CupcakeConfig.instance.didFoundInsecureBiometric = true;
                    CupcakeConfig.instance.save();
                    throw Exception(L.error_no_secure_biometric);
                  }

                  final bool didAuthenticate = await auth.authenticate(
                    localizedReason: L.biometric_authenticaion_reason,
                    options: AuthenticationOptions(
                      useErrorDialogs: true,
                      biometricOnly: !CupcakeConfig.instance.canUseInsecureBiometric,
                    ),
                  );
                  if (!didAuthenticate) {
                    throw Exception(L.error_didnt_authenticate);
                  }
                  await secureStorage.write(
                    key: "UI.${e.valueOutcome.uniqueId}",
                    value: e.ctrl.text,
                  );
                  CupcakeConfig.instance.biometricEnabled = true;
                  CupcakeConfig.instance.save();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(L.biometric_enabled),
                      ),
                    );
                  }
                  await nextPageCallback();
                } catch (err) {
                  await e.errorHandler(err);
                  return;
                }
              },
              showComma: false,
            ),
          const SizedBox(height: 128),
        ],
      );
    }
    _onLabelChange(null);
    final List<Widget> children = [];
    for (final e in viewModel.formElements) {
      if (e is StringFormElement) {
        if (e.showIf?.call() == false) continue;
        if (e.isExtra && !showExtra) {
          // If we return Container() some stuff happens on flutter render cache
          // and it doesn't render properly.
          continue;
        }
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                TextFormField(
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
                  onChanged: (final _) {},
                  textAlign: TextAlign.center,
                ),
                if (e.randomNameGenerator)
                  IconButton(
                    onPressed: () {
                      randomName(e.ctrl);
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
              ],
            ),
          ),
        );
        continue;
      } else if (e is PinFormElement) {
        if (e.showNumboard) continue;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 12.0, right: 12.0),
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
              onChanged: (final _) {},
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
