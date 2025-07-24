import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';

part 'form_builder_view_model.g.dart';

class FormBuilderViewModel = FormBuilderViewModelBase with _$FormBuilderViewModel;

abstract class FormBuilderViewModelBase extends ViewModel with Store {
  FormBuilderViewModelBase({
    required this.formElements,
    required this.scaffoldContext,
    final void Function(String? suggestedTitle)? onLabelChange,
    final void Function(bool val)? toggleIsPinSet,
    required final bool isPinSet,
  })  : _onLabelChange = onLabelChange,
        _toggleIsPinSet = toggleIsPinSet,
        _isPinSet = isPinSet;

  @observable
  List<FormElement> formElements;

  BuildContext scaffoldContext;

  @observable
  bool isPinInput = true;

  @action
  void onLabelChange(final String? suggestedTitle) => _onLabelChange?.call(suggestedTitle);

  final void Function(String? suggestedTitle)? _onLabelChange;

  @action
  void toggleIsPinSet(final bool val) => _toggleIsPinSet?.call(val);

  final void Function(bool val)? _toggleIsPinSet;

  @observable
  bool _isPinSet;

  @computed
  bool get isPinSet => _isPinSet;

  @computed
  set isPinSet(final bool val) {
    _isPinSet = val;
    toggleIsPinSet(val);
  }

  @action
  Future<void> enableSystemAuth(
    final PinFormElement e,
    final Future<void> Function() nextPageCallback,
  ) async {
    try {
      await e.onConfirmInternal(c!);
      final auth = LocalAuthentication();

      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        throw Exception(L.error_no_biometric_authentication);
      }
      if (!availableBiometrics.contains(BiometricType.strong) &&
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
      if (c!.mounted) {
        ScaffoldMessenger.of(c!).showSnackBar(
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
  }
}
