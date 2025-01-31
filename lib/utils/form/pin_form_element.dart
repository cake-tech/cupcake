import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/abstract_value_outcome.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/utils/form/default_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

final auth = LocalAuthentication();

class PinFormElement extends FormElement {
  PinFormElement({
    String initialText = "",
    this.password = false,
    this.validator = defaultFormValidator,
    required this.valueOutcome,
    this.onChanged,
    this.onConfirm,
    this.showNumboard = true,
    required this.label,
  }) : ctrl = TextEditingController(text: initialText);

  Future<void> loadSecureStorageValue(VoidCallback callback) async {
    if (ctrl.text.isNotEmpty) return;
    if (!config.biometricEnabled) return;
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

  Future<void> Function(BuildContext context)? onChanged;
  Future<void> Function(BuildContext context)? onConfirm;
  Future<void> onConfirmInternal(BuildContext context) async {
    await valueOutcome.encode(ctrl.text);
    isConfirmed = true;
  }

  bool isConfirmed = false;
  String? Function(String? input) validator;
}
