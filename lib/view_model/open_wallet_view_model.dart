import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/view_model/abstract.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/views/wallet_home.dart';
import 'package:flutter/cupertino.dart';

class OpenWalletViewModel extends ViewModel {
  OpenWalletViewModel({required this.coinInfo});

  CoinWalletInfo coinInfo;

  @override
  String get screenName => "Enter Password";

  late PinFormElement walletPassword = PinFormElement(
      password: true,
      validator: (String? input) {
        if (input == null) return "Input cannot be null";
        if (input == "") return "Input cannot be empty";
        if (input.length < 4) {
          return "Password needs to be at least 4 characters long";
        }
        return null;
      },
      onChanged: openWalletIfPasswordCorrect,
      onConfirm: openWallet);

  Future<void> openWallet(BuildContext context) async {
    callThrowable(
      context,
      () async => await _openWallet(context),
      "Opening wallet",
    );
  }

  Future<void> _openWallet(BuildContext context) async {
    final coin = await coinInfo.openWallet(
      context,
      password: walletPassword.value,
    );
    WalletHome.pushStatic(context, coin);
  }

  Future<bool> checkWalletPassword() {
    return coinInfo.checkWalletPassword(walletPassword.value);
  }

  Future<void> openWalletIfPasswordCorrect(BuildContext context) async {
    if (await checkWalletPassword()) {
      if (!context.mounted) return;
      openWallet(context);
    }
  }
}
