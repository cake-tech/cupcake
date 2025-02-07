import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/abstract_value_outcome.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class PinFormElement extends FormElement {
  PinFormElement(
      {final String initialText = "",
      this.password = false,
      required this.validator,
      required this.valueOutcome,
      this.onChanged,
      this.onConfirm,
      this.showNumboard = true,
      required this.label,
      required final Future<void> Function(Object e) errorHandler})
      : ctrl = TextEditingController(text: initialText),
        _errorHandler = errorHandler;
  final Future<void> Function(Object e) _errorHandler;
  Future<void> loadSecureStorageValue(final VoidCallback callback) async {
    if (ctrl.text.isNotEmpty) return;
    if (!CupcakeConfig.instance.biometricEnabled) return;
    final auth = LocalAuthentication();

    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) return;
    if (!availableBiometrics.contains(BiometricType.fingerprint) &&
        !availableBiometrics.contains(BiometricType.face)) {
      return;
    }

    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Authenticate...',
      options: const AuthenticationOptions(
          useErrorDialogs: true, biometricOnly: true),
    );
    if (!didAuthenticate) return;
    final value = await secureStorage.read(key: "UI.${valueOutcome.uniqueId}");
    if (value == null) return;
    ctrl.text = value;
    await Future.delayed(Duration.zero);
    callback();
  }

  TextEditingController ctrl;
  bool password;
  bool showNumboard;

  @override
  String label;

  ValueOutcome valueOutcome;

  @override
  Future<String> get value async => await valueOutcome.decode(ctrl.text);

  @override
  bool get isOk => validator(ctrl.text) == null;

  Future<void> Function()? onChanged;
  Future<void> Function()? onConfirm;
  Future<void> onConfirmInternal(final BuildContext context) async {
    await valueOutcome.encode(ctrl.text);
    isConfirmed = true;
  }

  bool isConfirmed = false;
  String? Function(String? input) validator;

  @override
  Future<void> errorHandler(final Object e) async {
    await _errorHandler(e);
  }
}
