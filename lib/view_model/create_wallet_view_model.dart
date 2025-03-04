import 'dart:async';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/types.dart';
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
import 'package:mobx/mobx.dart';

part 'create_wallet_view_model.g.dart';

class CreateWalletViewModel = CreateWalletViewModelBase with _$CreateWalletViewModel;

abstract class CreateWalletViewModelBase extends ViewModel with Store {
  CreateWalletViewModelBase({
    required this.createMethod,
    required this.needsPasswordConfirm,
  });

  final CreateMethod createMethod;

  @observable
  bool isPinSet = false;

  @observable
  bool showExtra = false;

  @override
  @observable
  late String screenName = screenNameOriginal;

  String get screenNameOriginal => switch (createMethod) {
        CreateMethod.create => L.create_wallet,
        CreateMethod.restore => L.restore_wallet,
      };

  @computed
  List<Coin> get coins => walletCoins;

  @computed
  bool get hasAdvancedOptions {
    if (currentForm == null) return false;
    for (final elm in currentForm!) {
      if (elm is StringFormElement) {
        if (elm.isExtra) return true;
      }
    }
    return false;
  }

  @observable
  late Coin? selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  late final StringFormElement walletName = StringFormElement(
    L.wallet_name,
    validator: nonEmptyValidator(L),
    randomNameGenerator: true,
    errorHandler: errorHandler,
  );

  late final PinFormElement walletPasswordInitial = PinFormElement(
    label: L.wallet_password,
    password: true,
    valueOutcome: PlainValueOutcome(),
    validator: nonEmptyValidator(
      L,
      extra: (final input) => (input.length < 4) ? L.warning_password_too_short : null,
    ),
    errorHandler: errorHandler,
  );

  late final PinFormElement walletPassword = PinFormElement(
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

  @observable
  late List<FormElement>? currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  @observable
  WalletCreation? creationMethod;

  @computed
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

  Future<void> completeSetup(final CoinWallet cw) async {
    await callThrowable(
      () async {
        CupcakeConfig.instance.initialSetupComplete = true;
        CupcakeConfig.instance.save();
        await WalletHome(coinWallet: cw).push(c!);
      },
      L.error_failed_to_setup,
    );
  }

  Future<void> createWallet() async {
    await callThrowable(
      () async {
        await _createWallet();
      },
      L.create_wallet,
    );
  }

  Future<void> _createWallet() async {
    if (selectedCoin == null) throw Exception(L.error_selected_coin_null);
    if ((await walletName.value).isEmpty) {
      throw Exception(L.warning_input_cannot_be_empty);
    }

    if (await walletPassword.value == await walletPasswordInitial.value) {
      throw Exception(L.password_doesnt_match);
    }

    final outcome = await creationMethod!.create(
      createMethod,
      await walletName.value,
      await walletPassword.value,
    );

    if (outcome == null) {
      throw Exception(L.error_unable_to_create_wallets_using_any_known_methods);
    }

    if (!outcome.success) {
      if (outcome.message == null || outcome.message?.isEmpty == true) {
        throw Exception(L.error_status_is_failure_no_message);
      }
      throw Exception(outcome.message);
    }

    if (outcome.wallet == null) {
      throw Exception(L.error_wallet_is_null_no_indication_of_failure);
    }

    final List<NewWalletInfoPage> pages = [
      NewWalletInfoPage.preShowSeedPage(L),
      NewWalletInfoPage.writeDownNotice(
        L,
        nextCallback:
            outcome.wallet!.passphrase.isEmpty ? () => completeSetup(outcome.wallet!) : null,
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
      throw Exception(L.error_context_not_mounted);
    }
    if (outcome.method == CreateMethod.restore) {
      await WalletHome(coinWallet: outcome.wallet!).push(c!);
    } else {
      await NewWalletInfoScreen(
        pages: pages,
      ).push(c!);
    }
  }

  Future<void> titleUpdate(final String? suggestedTitle) async {
    screenName = suggestedTitle ?? screenNameOriginal;
  }
}
