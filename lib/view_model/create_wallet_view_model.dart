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

enum CreateMethods {
  create,
  restoreSeedPolyseed,
  restoreSeedLegacy,
  restoreKeysDeterministic,
  restoreKeys
}

enum CreateMethod {
  any,
  create,
  restore,
}

class CreateWalletViewModel extends ViewModel {
  CreateWalletViewModel({
    required this.createMethod,
  });

  final CreateMethod createMethod;

  bool isPinSet = false;
  bool showExtra = false;
  @override
  String get screenName => L.create_wallet;

  List<Coin> get coins => walletCoins;

  bool isCreate = true;

  void toggleAdvancedOptions() {
    showExtra = !showExtra;
    markNeedsBuild();
  }

  late Coin? selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  late StringFormElement walletName =
      StringFormElement(L.wallet_name, validator: (String? input) {
    if (input == null) return L.warning_input_cannot_be_null;
    if (input == "") return L.warning_input_cannot_be_empty;
    return null;
  });

  late SingleChoiceFormElement walletSeedType = SingleChoiceFormElement(
    title: L.seed_type,
    elements: [
      L.seed_type_polyseed,
      L.seed_type_legacy,
    ],
  );

  late PinFormElement walletPassword = PinFormElement(
    label: "Wallet password",
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: true,
      verifyMatching: false,
    ),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
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

  late final List<FormElement> _createForm = [
    walletPassword,
    walletName,
    walletSeedType,
    seedOffset
  ];

  late final List<FormElement> _restoreSeedForm = [
    walletPassword,
    walletName,
    seed,
    seedOffset
  ];

  late final List<FormElement> _restoreFormKeysForm = [
    walletPassword,
    walletName,
    walletAddress,
    secretSpendKey,
    secretViewKey,
  ];

  Future<void> createWallet(BuildContext context) async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    print(currentForm == _createForm);
    final cw = await selectedCoin!.createNewWallet(
      await walletName.value,
      await walletPassword.value,
      primaryAddress: nullIfEmpty(await walletAddress.value),
      createWallet: (currentForm == _createForm),
      seed: nullIfEmpty(await seed.value),
      restoreHeight: int.tryParse(await restoreHeight.value),
      viewKey: nullIfEmpty(await secretViewKey.value),
      spendKey: nullIfEmpty(await secretSpendKey.value),
      seedOffsetOrEncryption: nullIfEmpty(await seedOffset.value),
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
  }) : ctrl = TextEditingController(text: initialText);

  TextEditingController ctrl;
  bool password;
  @override
  String label;
  @override
  Future<String> get value => Future.value(ctrl.text);

  bool isExtra;

  @override
  bool get isOk => validator(ctrl.text) == null;

  String? Function(String? input) validator;
}

abstract class ValueOutcome {
  Future<void> encode(String input);
  Future<String> decode(String output);
}

class PlainValueOutcome implements ValueOutcome {
  @override
  Future<String> decode(String output) => Future.value(output);

  @override
  Future<void> encode(String input) => Future.value();
}

class FlutterSecureStorageValueOutcome implements ValueOutcome {
  FlutterSecureStorageValueOutcome(this.key,
      {required this.canWrite, required this.verifyMatching});

  final String key;
  final bool canWrite;
  final bool verifyMatching;

  @override
  Future<void> encode(String input) async {
    var valInput =
        await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (valInput == null) {
      await secureStorage.write(
          key: "FlutterSecureStorageValueOutcome._$key", value: input);
      valInput = await secureStorage.read(
          key: "FlutterSecureStorageValueOutcome._$key");
    }
    if (input != valInput && verifyMatching) {
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
    var valInput =
        await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (output != valInput && verifyMatching) {
      throw Exception("Input doesn't match the secure element value");
    }
    final input = await secureStorage.read(key: key);
    if (input == null) {
      throw Exception("no secure storage $key found");
    }
    return "$input/$output";
  }
}

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
  }

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
