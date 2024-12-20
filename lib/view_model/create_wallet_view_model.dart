import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/null_if_empty.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/new_wallet_info_view_model.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';

enum CreateMethod {
  any,
  create,
  restore,
}

class CreateWalletViewModel extends ViewModel {
  CreateWalletViewModel({
    required this.createMethod,
    required this.needsPasswordConfirm,
  });

  final CreateMethod createMethod;

  bool isPinSet = false;
  bool showExtra = false;

  @override
  late String screenName = screenNameOriginal;

  String get screenNameOriginal => switch (createMethod) {
        CreateMethod.any => L.create_wallet,
        CreateMethod.create => L.create_wallet,
        CreateMethod.restore => L.restore_wallet,
      };

  List<Coin> get coins => walletCoins;

  bool isCreate = true;

  bool get hasAdvancedOptions {
    if (currentForm == null) return false;
    for (final elm in currentForm!) {
      if (elm is StringFormElement) {
        if (elm.isExtra) return true;
      }
    }
    return false;
  }

  void toggleAdvancedOptions() {
    print("toggling");
    showExtra = !showExtra;
    markNeedsBuild();
  }

  late Coin? selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  late StringFormElement walletName = StringFormElement(
    L.wallet_name,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
    randomNameGenerator: true,
  );

  late SingleChoiceFormElement walletSeedType = SingleChoiceFormElement(
    title: L.seed_type,
    elements: [
      L.seed_type_polyseed,
      L.seed_type_legacy,
    ],
  );

  late PinFormElement walletPasswordInitial = PinFormElement(
    label: L.wallet_password,
    password: true,
    valueOutcome: PlainValueOutcome(),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
      }
      return null;
    },
  );

  late PinFormElement walletPassword = PinFormElement(
    label:
        (needsPasswordConfirm) ? L.wallet_password_repeat : L.wallet_password,
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: true,
      verifyMatching: true,
    ),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
      }
      if (input != walletPasswordInitial.ctrl.text && needsPasswordConfirm) {
        return L.password_doesnt_match;
      }
      return null;
    },
  );

  late StringFormElement seed = StringFormElement(
    L.wallet_seed,
    password: false,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.split(" ").length != 16 && input.split(" ").length != 25) {
        return L.warning_seed_incorrect_length;
      }
      return null;
    },
  );

  late StringFormElement walletAddress = StringFormElement(
    L.primary_address_label,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement secretSpendKey = StringFormElement(
    L.secret_spend_key,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement secretViewKey = StringFormElement(
    L.secret_view_key,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement restoreHeight = StringFormElement(
    L.restore_height,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement seedOffset = StringFormElement(
    L.seed_offset,
    password: true,
    isExtra: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late List<FormElement>? currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  Map<String, List<FormElement>> get createMethods => {
        if ([CreateMethod.any, CreateMethod.create].contains(createMethod))
          L.option_create_new_wallet: _createForm,
        if ([CreateMethod.any, CreateMethod.restore]
            .contains(createMethod)) ...{
          L.option_create_seed: _restoreSeedForm,
          L.option_create_keys: _restoreFormKeysForm,
        },
      };

  bool needsPasswordConfirm;

  late final List<FormElement> _createForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    walletSeedType,
    seedOffset
  ];

  late final List<FormElement> _restoreSeedForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    seed,
    seedOffset
  ];

  late final List<FormElement> _restoreFormKeysForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    walletAddress,
    secretSpendKey,
    secretViewKey,
  ];

  Future<void> createWallet(BuildContext context) async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    if ((await walletName.value).isEmpty) {
      throw Exception(L.warning_input_cannot_be_empty);
    }
    print(currentForm == _createForm);
    final cw = await selectedCoin!.createNewWallet(
      await walletName.value,
      await walletPassword.value,
      primaryAddress: (await walletAddress.value).nullIfEmpty(),
      createWallet: (currentForm == _createForm),
      seed: (await seed.value).nullIfEmpty(),
      restoreHeight: int.tryParse(await restoreHeight.value),
      viewKey: (await secretViewKey.value).nullIfEmpty(),
      spendKey: (await secretSpendKey.value).nullIfEmpty(),
      seedOffsetOrEncryption: (await seedOffset.value).nullIfEmpty(),
    );

    final List<NewWalletInfoPage> pages = [
      NewWalletInfoPage(
        topText: L.important,
        topAction: null,
        topActionText: null,
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.nextPage,
            function: null,
            text: Text(
              L.understand_show_seed,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            L.important_seed_backup_info(
                "16 word"), // TODO: translate it better?
            textAlign: TextAlign.center,
          ),
        ],
      ),
      NewWalletInfoPage(
        topText: L.seed,
        topAction: seedOffset.ctrl.text.isNotEmpty
            ? null
            : () {
                config.initialSetupComplete = true;
                config.save();
                WalletHome.pushStatic(context, cw);
              },
        topActionText: Text(L.next),
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Share.share(cw.seed);
            },
            text: Text(
              L.save,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Clipboard.setData(ClipboardData(text: cw.seed));
            },
            text: Text(
              L.copy,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            cw.walletName,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            "${cw.seed}\n\n\n\n${L.write_down_notice}",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      if (seedOffset.ctrl.text.isNotEmpty)
        NewWalletInfoPage(
          topText: L.wallet_passphrase,
          topAction: () {
            config.initialSetupComplete = true;
            config.save();
            WalletHome.pushStatic(context, cw);
          },
          topActionText: Text(L.next),
          lottieAnimation: Assets.shield.lottie(),
          actions: [
            NewWalletAction(
              type: NewWalletActionType.function,
              function: () {
                Share.share(cw.seed);
              },
              text: Text(
                L.save,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
            NewWalletAction(
              type: NewWalletActionType.function,
              function: () {
                Clipboard.setData(ClipboardData(text: cw.seed));
              },
              text: Text(
                L.copy,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
          ],
          texts: [
            Text(
              cw.walletName,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              "${seedOffset.value}\n\n\n\n${L.write_down_notice}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
    ];
    if (!context.mounted) {
      throw Exception("context is not mounted, unable to show next screen");
    }
    if (currentForm != _createForm) {
      WalletHome.pushStatic(context, cw);
    } else {
      NewWalletInfoScreen.staticPush(
        context,
        NewWalletInfoViewModel(pages),
      );
    }
  }

  void titleUpdate(String? suggestedTitle) async {
    await Future.delayed(Duration.zero); // don't do it on build();
    screenName = suggestedTitle ?? screenNameOriginal;
    markNeedsBuild();
  }
}

String? _defaultValidator(String? input) {
  return null;
}

class StringFormElement extends FormElement {
  StringFormElement(
    this.label, {
    String initialText = "",
    this.password = false,
    this.validator = _defaultValidator,
    this.isExtra = false,
    this.showIf,
    this.randomNameGenerator = false,
  }) : ctrl = TextEditingController(text: initialText);

  bool Function()? showIf;
  TextEditingController ctrl;
  bool password;
  @override
  String label;
  @override
  Future<String> get value => Future.value(ctrl.text);

  bool isExtra;
  bool randomNameGenerator;

  @override
  bool get isOk => validator(ctrl.text) == null;

  String? Function(String? input) validator;
}

abstract class ValueOutcome {
  Future<void> encode(String input);
  Future<String> decode(String output);

  String get uniqueId => throw UnimplementedError();
}

class PlainValueOutcome implements ValueOutcome {
  @override
  Future<String> decode(String output) => Future.value(output);

  @override
  Future<void> encode(String input) => Future.value();

  @override
  String get uniqueId => "undefined";
}

class FlutterSecureStorageValueOutcome implements ValueOutcome {
  FlutterSecureStorageValueOutcome(this.key,
      {required this.canWrite, required this.verifyMatching});

  final String key;
  final bool canWrite;
  final bool verifyMatching;

  @override
  Future<void> encode(String input) async {
    List<int> bytes = utf8.encode(input);
    Digest sha512Hash = sha512.convert(bytes);
    var valInput =
        await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (valInput == null) {
      await secureStorage.write(
          key: "FlutterSecureStorageValueOutcome._$key",
          value: sha512Hash.toString());
      valInput = await secureStorage.read(
          key: "FlutterSecureStorageValueOutcome._$key");
    }
    if (sha512Hash.toString() != valInput && verifyMatching) {
      throw Exception("Input doesn't match the secure element value");
    }

    final input_ = await secureStorage.read(key: key);
    // Do not update secret if it is already set.
    if (input_ != null) {
      return;
    }
    if (!canWrite) {
      if (config.debug) {
        throw Exception(
            "DEBUG_ONLY: canWrite is false but we tried to flush the value");
      }
      return;
    }
    var random = Random.secure();
    var values = List<int>.generate(64, (i) => random.nextInt(256));
    final pass = base64Url.encode(values);
    await secureStorage.write(key: key, value: pass);
    return;
  }

  @override
  Future<String> decode(String output) async {
    List<int> bytes = utf8.encode(output);
    Digest sha512Hash = sha512.convert(bytes);
    var valInput =
        await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (sha512Hash.toString() != valInput && verifyMatching) {
      throw Exception("Input doesn't match the secure element value");
    }
    final input = await secureStorage.read(key: key);
    if (input == null) {
      throw Exception("no secure storage $key found");
    }
    return "$input/$output";
  }

  @override
  // TODO: implement uniqueId
  String get uniqueId => key;
}

final LocalAuthentication auth = LocalAuthentication();

class PinFormElement extends FormElement {
  PinFormElement({
    String initialText = "",
    this.password = false,
    this.validator = _defaultValidator,
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

class SingleChoiceFormElement extends FormElement {
  SingleChoiceFormElement({required this.title, required this.elements});
  String title;
  List<String> elements;

  int currentSelection = 0;

  @override
  Future<String> get value => Future.value(valueSync);
  String get valueSync => elements[currentSelection];

  @override
  bool get isOk => true;
}

class FormElement {
  bool get isOk => true;
  String get label => throw UnimplementedError();
  Future<String> get value => throw UnimplementedError();
}
