import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:flutter/cupertino.dart';

class OpenWalletViewModel extends ViewModel {
  OpenWalletViewModel({required this.coinWalletInfo});

  CoinWalletInfo coinWalletInfo;

  @override
  String get screenName => L.enter_password;

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
    onChanged: openWalletIfPasswordCorrect,
    onConfirm: openWallet,
  );

  Future<void> openWallet(BuildContext context) async {
    callThrowable(
      context,
      () async => await _openWallet(context),
      L.opening_wallet,
    );
  }

  Future<void> _openWallet(BuildContext context) async {
    final wallet = await coinWalletInfo.openWallet(
      context,
      password: await walletPassword.value,
    );
    WalletHome(coinWallet: wallet).push(context);
  }

  Future<bool> checkWalletPassword() async {
    try {
      return coinWalletInfo.checkWalletPassword(await walletPassword.value);
    } catch (e) {
      return false;
    }
  }

  Future<void> openWalletIfPasswordCorrect(BuildContext context) async {
    if (await checkWalletPassword()) {
      if (!context.mounted) return;
      openWallet(context);
    }
  }

  void titleUpdate(String? suggestedTitle) {}
}
