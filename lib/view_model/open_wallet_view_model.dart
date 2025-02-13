import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/wallet_home.dart';

part 'open_wallet_view_model.g.dart';

@GenerateRebuild()
class OpenWalletViewModel extends ViewModel {
  OpenWalletViewModel({required this.coinWalletInfo});

  final CoinWalletInfo coinWalletInfo;

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
    validator: nonEmptyValidator(
      L,
      extra: (final input) => (input.length < 4) ? L.warning_password_too_short : null,
    ),
    onChanged: openWalletIfPasswordCorrect,
    onConfirm: openWallet,
    errorHandler: errorHandler,
  );

  @ThrowOnUI(message: "Opening wallet")
  Future<void> $openWallet() async {
    final wallet = await coinWalletInfo.openWallet(
      c!,
      password: await walletPassword.value,
    );
    await WalletHome(coinWallet: wallet).push(c!);
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

  void titleUpdate(final String? suggestedTitle) {}
}
