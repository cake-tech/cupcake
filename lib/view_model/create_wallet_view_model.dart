import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/list.dart';
import 'package:cup_cake/utils/null_if_empty.dart';
import 'package:cup_cake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';

enum CreateMethods {
  create,
  restoreSeedPolyseed,
  restoreSeedLegacy,
  restoreKeysDeterministic,
  restoreKeys
}

class CreateWalletViewModel extends ViewModel {
  CreateWalletViewModel();

  @override
  String get screenName => "Create Wallet";

  List<Coin> get coins => walletCoins;

  bool isCreate = true;

  Coin? selectedCoin;

  StringFormElement walletName =
      StringFormElement("Wallet name", validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    return null;
  });
  StringFormElement walletPassword = StringFormElement("Wallet password",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.length < 4) {
      return "Password needs to be at least 4 characters long";
    }
    return null;
  });

  StringFormElement polyseedSeed = StringFormElement("Wallet seed",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16) {
      return "Seed needs to contain exactly 16 words";
    }
    return null;
  });

  StringFormElement legacySeed = StringFormElement("Wallet seed",
      password: true, validator: (String? input) {
    if (input == null) return "Input cannot be null";
    if (input == "") return "Input cannot be empty";
    if (input.split(" ").length != 16) {
      return "Seed needs to contain exactly 16 words";
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

  List<FormElement>? currentForm;

  Map<String, List<FormElement>> get createMethods => {
        "New wallet": _createForm,
        "New wallet (offset)": _createOffsetForm,
        "New wallet (encrypted)": _createEncryptedForm,
        "Polyseed": _restoreSeedPolyseedForm,
        "Legacy Seed": _restoreSeedLegacyForm,
        "Keys": _restoreFormKeysForm,
      };

  late final List<FormElement> _createForm = [
    walletName,
    walletPassword,
  ];

  late final List<FormElement> _createOffsetForm = [
    walletName,
    walletPassword,
    seedOffset,
  ];

  late final List<FormElement> _createEncryptedForm = [
    walletName,
    walletPassword,
    seedOffset,
  ];

  late final List<FormElement> _restoreSeedPolyseedForm = [
    walletName,
    walletPassword,
    polyseedSeed,
  ];

  late final List<FormElement> _restoreSeedLegacyForm = [
    walletName,
    walletPassword,
    legacySeed,
    restoreHeight,
  ];

  late final List<FormElement> _restoreFormKeysForm = [
    walletName,
    walletPassword,
    walletAddress,
    secretSpendKey,
    secretViewKey,
  ];

  Future<void> createWallet() async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    print(currentForm == _createForm);
    await selectedCoin!.createNewWallet(
      walletName.value,
      walletPassword.value,
      primaryAddress: nullIfEmpty(walletAddress.value),
      createWallet: (currentForm == _createForm),
      seed: (currentForm == _restoreSeedLegacyForm)
          ? nullIfEmpty(legacySeed.value)
          : nullIfEmpty(polyseedSeed.value),
      restoreHeight: int.tryParse(restoreHeight.value),
      viewKey: nullIfEmpty(secretViewKey.value),
      spendKey: nullIfEmpty(secretSpendKey.value),
      seedOffsetOrEncryption: nullIfEmpty(seedOffset.value),
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

class FormElement {
  bool get isOk => true;
  String get label => throw UnimplementedError();
  dynamic get value => throw UnimplementedError();
}
