import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/abstract_value_outcome.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart';

part 'pin_form_element.g.dart';

class PinFormElement = PinFormElementBase with _$PinFormElement;

abstract class PinFormElementBase extends FormElement with Store {
  PinFormElementBase({
    final String initialText = "",
    this.password = false,
    required this.validator,
    required this.valueOutcome,
    this.onChanged,
    this.onConfirm,
    this.showNumboard = true,
    required this.label,
    required this.errorHandler,
    required this.enableBiometric,
  }) : ctrl = TextEditingController(text: initialText);

  final bool enableBiometric;

  @override
  bool get isExtra => false;

  @action
  Future<void> loadSecureStorageValue(final VoidCallback callback) async {
    if (ctrl.text.isNotEmpty) return;
    if (!CupcakeConfig.instance.biometricEnabled) return;
    final auth = LocalAuthentication();

    final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) return;
    if (!availableBiometrics.contains(BiometricType.strong) &&
        !CupcakeConfig.instance.canUseInsecureBiometric) {
      return;
    }
    bool didAuthenticate = false;
    try {
      didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate...',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      didAuthenticate = false;
    }
    if (!didAuthenticate) return;
    final value = await secureStorage.read(key: "UI.${valueOutcome.uniqueId}");
    if (value == null) return;
    ctrl.text = value;
    await Future.delayed(Duration.zero);
    callback();
  }

  TextEditingController ctrl;

  final bool password;
  final bool showNumboard;

  @override
  final String label;

  final ValueOutcome valueOutcome;

  @computed
  @override
  Future<String> get value => valueOutcome.decode(ctrl.text);

  @computed
  @override
  bool get isOk => validator(ctrl.text) == null;

  Future<void> Function()? onChanged;
  Future<void> Function()? onConfirm;

  @action
  Future<void> onConfirmInternal(final BuildContext context) async {
    try {
      await valueOutcome.encode(ctrl.text);
    } catch (e) {
      await clear();
      rethrow;
    }
    isConfirmed = true;
  }

  @observable
  bool isConfirmed = false;
  String? Function(String? input) validator;

  @override
  Future<void> Function(Object e) errorHandler;

  @override
  Future<void> clear() async {
    ctrl.clear();
  }
}
