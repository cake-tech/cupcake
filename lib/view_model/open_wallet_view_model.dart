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
  String get screenName => L.enter_password;

  late PinFormElement walletPassword = PinFormElement(
      password: true,
      valueOutcome: FlutterSecureStorageValueOutcome(
        "secure.wallet_password",
        canWrite: false,
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
      onConfirm: openWallet);

  Future<void> openWallet(BuildContext context) async {
    callThrowable(
      context,
      () async => await _openWallet(context),
      L.opening_wallet,
    );
  }

  Future<void> _openWallet(BuildContext context) async {
    final coin = await coinInfo.openWallet(
      context,
      password: await walletPassword.value,
    );
    WalletHome.pushStatic(context, coin);
  }

  Future<bool> checkWalletPassword() async {
    return coinInfo.checkWalletPassword(await walletPassword.value);
  }

  Future<void> openWalletIfPasswordCorrect(BuildContext context) async {
    if (await checkWalletPassword()) {
      if (!context.mounted) return;
      openWallet(context);
    }
  }
}
