import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:mobx/mobx.dart';

part 'open_wallet_view_model.g.dart';

class OpenWalletViewModel = OpenWalletViewModelBase with _$OpenWalletViewModel;

abstract class OpenWalletViewModelBase extends ViewModel with Store {
  OpenWalletViewModelBase({required this.coinWalletInfo});

  final CoinWalletInfo coinWalletInfo;

  @override
  String get screenName => L.enter_password;

  late PinFormElement walletPassword = PinFormElement(
    label: L.wallet_password,
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: false,
      verifyMatching: true,
    ),
    validator: nonEmptyValidator(
      L,
      extra: (final input) => (input.length < 4) ? L.warning_password_too_short : null,
    ),
    onChanged: openWalletIfPasswordCorrect,
    onConfirm: openWallet,
    errorHandler: errorHandler,
  );

  Future<void> openWallet() async {
    await callThrowable(
      () async {
        final wallet = await coinWalletInfo.openWallet(
          c!,
          password: await walletPassword.value,
        );
        await WalletHome(coinWallet: wallet).push(c!);
      },
      L.opening_wallet,
    );
  }

  Future<bool> checkWalletPassword() async {
    try {
      return coinWalletInfo.checkWalletPassword(await walletPassword.value);
    } catch (e) {
      return false;
    }
  }

  Future<void> openWalletIfPasswordCorrect() async {
    if (await checkWalletPassword()) {
      if (!mounted) return;
      return openWallet();
    }
  }
}
