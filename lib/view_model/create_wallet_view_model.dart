import 'dart:async';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/plain_value_outcome.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:cupcake/views/widgets/form_builder.dart';

part 'create_wallet_view_model.g.dart';

@GenerateRebuild()
class CreateWalletViewModel extends ViewModel {
  CreateWalletViewModel({
    required this.createMethod,
    required this.needsPasswordConfirm,
  });

  final CreateMethod createMethod;

  @RebuildOnChange()
  bool $isPinSet = false;

  @RebuildOnChange()
  bool $showExtra = false;

  @override
  late String screenName = screenNameOriginal;

  String get screenNameOriginal => switch (createMethod) {
        CreateMethod.create => L.create_wallet,
        CreateMethod.restore => L.restore_wallet,
      };

  List<Coin> get coins => walletCoins;

  bool get hasAdvancedOptions {
    if (currentForm == null) return false;
    for (final elm in currentForm!) {
      if (elm is StringFormElement) {
        if (elm.isExtra) return true;
      }
    }
    return false;
  }

  @RebuildOnChange()
  late Coin? $selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  late StringFormElement walletName = StringFormElement(
    L.wallet_name,
    validator: nonEmptyValidator(L),
    randomNameGenerator: true,
    errorHandler: errorHandler,
  );

  late PinFormElement walletPasswordInitial = PinFormElement(
    label: L.wallet_password,
    password: true,
    valueOutcome: PlainValueOutcome(),
    validator: nonEmptyValidator(
      L,
      extra: (final input) => (input.length < 4) ? L.warning_password_too_short : null,
    ),
    errorHandler: errorHandler,
  );

  late PinFormElement walletPassword = PinFormElement(
    label: (needsPasswordConfirm) ? L.wallet_password_repeat : L.wallet_password,
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: true,
      verifyMatching: true,
    ),
    validator: nonEmptyValidator(
      L,
      extra: (final String input) {
        if (input.length < 4) {
          return L.warning_password_too_short;
        }
        if (input != walletPasswordInitial.ctrl.text && needsPasswordConfirm) {
          return L.password_doesnt_match;
        }
        return null;
      },
    ),
    errorHandler: errorHandler,
  );

  @RebuildOnChange()
  late List<FormElement>? $currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  WalletCreation? creationMethod;
  Map<String, List<FormElement>> get createMethods {
    if (creationMethod == null || creationMethod!.coin != selectedCoin) {
      creationMethod = selectedCoin!.creationMethod(L);
      creationMethod!.wipe();
    }
    final form = creationMethod!.createMethods(createMethod);
    final Map<String, List<FormElement>> toRet = {};
    for (final key in form.keys) {
      toRet[key] = [
        if (needsPasswordConfirm) walletPasswordInitial,
        walletPassword,
        walletName,
      ];
      toRet[key]!.addAll(form[key]!);
    }
    return toRet;
  }

  final bool needsPasswordConfirm;

  @ThrowOnUI(message: "Failed to complete setup")
  Future<void> $completeSetup(final CoinWallet cw) async {
    CupcakeConfig.instance.initialSetupComplete = true;
    CupcakeConfig.instance.save();
    await WalletHome(coinWallet: cw).push(c!);
  }

  @ThrowOnUI(L: 'create_wallet')
  Future<void> $createWallet() async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    if ((await walletName.value).isEmpty) {
      throw Exception(L.warning_input_cannot_be_empty);
    }

    if (await walletPassword.value == await walletPasswordInitial.value) {
      throw Exception("Wallet password doesn't match");
    }

    final outcome = await creationMethod!.create(
      createMethod,
      await walletName.value,
      await walletPassword.value,
    );

    if (outcome == null) {
      throw Exception("Unable to create wallet using any known methods");
    }

    if (!outcome.success) {
      if (outcome.message == null || outcome.message?.isEmpty == true) {
        throw Exception(
            "Wallet creation failed, and status indicated failure but message was empty");
      }
      throw Exception(outcome.message);
    }

    if (outcome.wallet == null) {
      throw Exception("Wallet is null but there is no indication of failure");
    }

    final List<NewWalletInfoPage> pages = [
      NewWalletInfoPage.preShowSeedPage(L),
      NewWalletInfoPage.writeDownNotice(
        L,
        nextCallback:
            outcome.wallet!.passphrase.isEmpty ? () => completeSetup(outcome.wallet) : null,
        text: outcome.wallet!.seed,
        title: L.seed,
      ),
      if (outcome.wallet!.passphrase.isNotEmpty)
        NewWalletInfoPage.writeDownNotice(
          L,
          nextCallback: () => completeSetup(outcome.wallet!),
          text: outcome.wallet!.passphrase,
          title: L.wallet_passphrase,
        ),
    ];
    if (!mounted) {
      throw Exception("context is not mounted, unable to show next screen");
    }
    if (outcome.method == CreateMethod.restore) {
      await WalletHome(coinWallet: outcome.wallet!).push(c!);
    } else {
      await NewWalletInfoScreen(
        pages: pages,
      ).push(c!);
    }
  }

  FormBuilder get formBuilder => FormBuilder(
        formElements: currentForm ?? [],
        scaffoldContext: c!,
        rebuild: (final bool val) {
          isPinSet = val;
        },
        isPinSet: isPinSet,
        showExtra: showExtra,
        onLabelChange: titleUpdate,
      );

  Future<void> titleUpdate(final String? suggestedTitle) async {
    await Future.delayed(Duration.zero); // don't do it on build();
    screenName = suggestedTitle ?? screenNameOriginal;
    markNeedsBuild();
  }
}
