import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/list.dart';
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

  StringFormElement walletSeed = StringFormElement("Wallet seed",
    password: true, validator: (String? input) {
      if (input == null) return "Input cannot be null";
      if (input == "") return "Input cannot be empty";
      if (input.split(" ").length != 16) {
        return "Password needs to be at least 4 characters long";
      }
      return null;
    });

  List<CreateMethods> get createMethods => selectedCoin?.createMethods??[];

  List<FormElement> get creationForm {
    return [
      walletName,
      walletPassword,
    ];
  }

  List<FormElement> get restoreFormSeed {
    return [
      walletName,

      walletPassword,
    ];
  }

  List<FormElement> get restoreFormKeys {
    return [
      walletName,

      walletPassword,
    ];
  }
  Future<void> createWallet() async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    await selectedCoin!.createNewWallet(walletName.value, walletPassword.value);
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
