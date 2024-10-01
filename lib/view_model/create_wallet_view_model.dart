import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/list.dart';
import 'package:cup_cake/utils/config.dart';
import 'package:cup_cake/utils/null_if_empty.dart';
import 'package:cup_cake/view_model/abstract.dart';
import 'package:cup_cake/view_model/new_wallet_info_view_model.dart';
import 'package:cup_cake/views/new_wallet_info.dart';
import 'package:cup_cake/const/resource.dart';
import 'package:cup_cake/views/wallet_home.dart';
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

  @override
  String get screenName => "Create Wallet";

  List<Coin> get coins => walletCoins;

  bool isCreate = true;

  late Coin? selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  StringFormElement walletName =
      StringFormElement("Wallet name", validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    return null;
  });

  SingleChoiceFormElement walletSeedType = SingleChoiceFormElement(
    title: "Seed type",
    elements: ["Polyseed (16 word)", "Legacy Seed (25 word)"],
  );

  PinFormElement walletPassword = PinFormElement(
      password: true,
      validator: (String? input) {
        if (input == null) return "Input cannot be null";
        if (input == "") return "Input cannot be empty";
        if (input.length < 4) {
          return "Password needs to be at least 4 characters long";
        }
        return null;
      });

  StringFormElement seed = StringFormElement("Wallet seed", password: true,
      validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16 && input.split(" ").length != 25) {
      return "Seed needs to contain exactly 16 or 25 words";
    }
    return null;
  });

  StringFormElement walletAddress = StringFormElement("Primary Address",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16) {
      return "Seed needs to contain exactly 16 words";
    }
    return null;
  });

  StringFormElement secretSpendKey = StringFormElement("Secret Spend Key",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16) {
      return "Seed needs to contain exactly 16 words";
    }
    return null;
  });

  StringFormElement secretViewKey = StringFormElement("Secret View Key",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16) {
      return "Seed needs to contain exactly 16 words";
    }
    return null;
  });

  StringFormElement restoreHeight = StringFormElement("Restore height",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (int.tryParse(input) == null) {
      return "Input must be a number";
    }
    return null;
  });

  StringFormElement seedOffset = StringFormElement("Seed offset",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    return null;
  });

  late List<FormElement>? currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  Map<String, List<FormElement>> get createMethods => {
        if ([CreateMethod.any, CreateMethod.create].contains(createMethod))
          "New wallet": _createForm,
        if ([CreateMethod.any, CreateMethod.restore]
            .contains(createMethod)) ...{
          "Seed": _restoreSeedForm,
          "Keys": _restoreFormKeysForm,
        },
      };

  late final List<FormElement> _createForm = [
    walletPassword,
    walletName,
    walletSeedType,
  ];

  late final List<FormElement> _restoreSeedForm = [
    walletPassword,
    walletName,
    seed,
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
      walletName.value,
      walletPassword.value,
      primaryAddress: nullIfEmpty(walletAddress.value),
      createWallet: (currentForm == _createForm),
      seed: nullIfEmpty(seed.value),
      restoreHeight: int.tryParse(restoreHeight.value),
      viewKey: nullIfEmpty(secretViewKey.value),
      spendKey: nullIfEmpty(secretSpendKey.value),
      seedOffsetOrEncryption: nullIfEmpty(seedOffset.value),
    );

    final List<NewWalletInfoPage> pages = [
      NewWalletInfoPage(
        topText: "IMPORTANT",
        topAction: null,
        topActionText: null,
        lottieAnimationAsset: R.ASSETS_SHIELD_JSON,
        actions: [
          NewWalletAction(
            type: NewWalletActionType.nextPage,
            function: null,
            text: const Text(
              "I understand. Show me the seed",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          const Text(
              "On the next page you will see a series of 16 words. This is your unique and private seed and it is the ONLY way to recover your wallet in case of loss or malfunction. It is YOUR responsibility to write it down and store it in a safe place outside of the Cake Wallet app.",
              textAlign: TextAlign.center),
        ],
      ),
      NewWalletInfoPage(
        topText: "Seed",
        topAction: () {
          config.initialSetupComplete = true;
          config.save();
          WalletHome.pushStatic(context, cw);
        },
        topActionText: const Text("Next"),
        lottieAnimationAsset: R.ASSETS_SHIELD_JSON,
        actions: [
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Share.share(cw.seed);
            },
            text: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Clipboard.setData(ClipboardData(text: cw.seed));
            },
            text: const Text(
              "Copy",
              style: TextStyle(color: Colors.white),
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
              "${cw.seed}\n\n\n\nPlease write these down in case you lose or wipe your phone",
              textAlign: TextAlign.center),
        ],
      ),
    ];
    if (!context.mounted) {
      throw Exception("context is not mounted, unable to show next screen");
    }
    NewWalletInfoScreen.staticPush(
      context,
      NewWalletInfoViewModel(pages),
    );
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
  }) : ctrl = TextEditingController(text: initialText);

  TextEditingController ctrl;
  bool password;
  @override
  String label;
  @override
  String get value => ctrl.text;

  @override
  bool get isOk => validator(value) == null;

  String? Function(String? input) validator;
}

class PinFormElement extends FormElement {
  PinFormElement({
    String initialText = "",
    this.password = false,
    this.validator = _defaultValidator,
    this.onChanged,
    this.onConfirm,
  }) : ctrl = TextEditingController(text: initialText);

  TextEditingController ctrl;
  bool password;
  @override
  String get value => ctrl.text;

  @override
  bool get isOk => validator(value) == null;

  Future<void> Function(BuildContext context)? onChanged;
  Future<void> Function(BuildContext context)? onConfirm;

  String? Function(String? input) validator;
}

class SingleChoiceFormElement extends FormElement {
  SingleChoiceFormElement({required this.title, required this.elements});
  String title;
  List<String> elements;

  int currentSelection = 0;

  @override
  String get value => elements[currentSelection];

  @override
  bool get isOk => true;
}

class FormElement {
  bool get isOk => true;
  String get label => throw UnimplementedError();
  dynamic get value => throw UnimplementedError();
}
