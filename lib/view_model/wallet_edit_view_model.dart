import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:path/path.dart' as p;

class WalletEditViewModel extends ViewModel {
  WalletEditViewModel({
    required this.walletInfo,
  });

  CoinWalletInfo walletInfo;

  late StringFormElement walletName = StringFormElement(
    "Wallet name",
    initialText: p.basename(walletInfo.walletName),
  );

  late PinFormElement walletPassword = PinFormElement(
    label: "Wallet password",
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: false,
      verifyMatching: true,
    ),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
      }
      return null;
    },
    showNumboard: false,
  );

  late final List<FormElement> form = [
    walletName,
    walletPassword,
  ];

  @override
  String get screenName => "Edit wallet";

  Future<void> deleteWallet(BuildContext context) async {
    if (!(await walletInfo.checkWalletPassword(await walletPassword.value))) {
      throw Exception("Invalid wallet password");
    }
    walletInfo.deleteWallet();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> renameWallet(BuildContext context) async {
    if (!(await walletInfo.checkWalletPassword(await walletPassword.value))) {
      throw Exception("Invalid wallet password");
    }
    walletInfo.renameWallet(await walletName.value);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
