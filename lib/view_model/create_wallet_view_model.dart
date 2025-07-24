import 'dart:async';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/display_form_element.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/plain_value_outcome.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/connect_wallet.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'create_wallet_view_model.g.dart';

class CreateWalletViewModel = CreateWalletViewModelBase with _$CreateWalletViewModel;

abstract class CreateWalletViewModelBase extends ViewModel with Store {
  CreateWalletViewModelBase({
    required this.createMethod,
    required this.needsPasswordConfirm,
  });

  @observable
  CreateMethod? createMethod;

  @observable
  int formIndex = 0;

  @override
  @computed
  bool get hasBackground {
    if (selectedCoin == null) return true;
    if (createMethod == null) return true;
    if (currentForm == null) return true;

    return !displayPinFormElement(currentForm!.form);
  }

  @observable
  bool isPinSet = false;

  @observable
  bool showExtra = false;

  @observable
  late List<FormBuilderViewModelBase> formBuilderViewModelList =
      List.generate(createMethods.length, (final index) {
    final formElements = createMethods.values.toList()[index].form;
    return FormBuilderViewModel(
      formElements: formElements,
      scaffoldContext: c!,
      isPinSet: false,
      toggleIsPinSet: (final bool val) {
        isPinSet = val;
      },
    );
  });

  @override
  @observable
  late String screenName = screenNameOriginal;

  String get screenNameOriginal => switch (createMethod) {
        CreateMethod.create => L.create_wallet,
        CreateMethod.restore => L.restore_wallet,
        null => L.create_new_wallet,
      };

  @computed
  List<Coin> get coins => walletCoins;

  @computed
  bool get hasAdvancedOptions {
    if (currentForm == null) return false;
    for (final elm in currentForm!.form) {
      if (elm.isExtra) return true;
    }
    return false;
  }

  @observable
  Coin? unconfirmedSelectedCoin;

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
    canPaste: false,
  );

  late final PinFormElement walletPasswordInitial = PinFormElement(
    label: L.setup_pin,
    password: true,
    valueOutcome: PlainValueOutcome(),
    validator: nonEmptyValidator(
      L,
      extra: (final input) => (input.length < 4) ? L.warning_password_too_short : null,
    ),
    errorHandler: errorHandler,
    enableBiometric: false,
  );

  late final PinFormElement walletPassword = PinFormElement(
    label: L.setup_pin,
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
    enableBiometric: false,
  );

  @observable
  late WalletCreationForm? currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  @observable
  WalletCreation? creationMethod;

  @computed
  Map<String, WalletCreationForm> get createMethods {
    if (creationMethod == null || creationMethod!.coin != selectedCoin) {
      creationMethod = selectedCoin!.creationMethod(L);
      creationMethod!.wipe();
    }
    final Map<String, WalletCreationForm> form = {
      if ([CreateMethod.create, null].contains(createMethod))
        ...creationMethod!.createMethods(CreateMethod.create),
      if ([CreateMethod.restore, null].contains(createMethod))
        ...creationMethod!.createMethods(CreateMethod.restore),
    };
    final Map<String, WalletCreationForm> toRet = {};
    for (final key in form.keys) {
      toRet[key] = WalletCreationForm(
        method: form[key]!.method,
        form: [
          if (needsPasswordConfirm) walletPasswordInitial,
          walletPassword,
          walletName,
          ...form[key]!.form,
        ],
      );
    }
    return toRet;
  }

  final bool needsPasswordConfirm;

  Future<void> completeSetup(final CoinWallet cw) async {
    await callThrowable(
      () async {
        CupcakeConfig.instance.initialSetupComplete = true;
        CupcakeConfig.instance.save();
        await ConnectWallet(wallet: cw, canSkip: true).push(c!);
        await WalletHome(coinWallet: cw).pushReplacement(c!);
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

    final walletPassword1 = walletPassword.ctrl.text;
    final walletPassword2 = walletPasswordInitial.ctrl.text;
    // verify that password match when confirming, ignore otherwise
    if (walletPassword1 != walletPassword2 && walletPassword2.isNotEmpty) {
      if (kDebugMode) {
        throw Exception("${L.password_doesnt_match} /$walletPassword1/$walletPassword2/");
      }
      throw Exception(L.password_doesnt_match);
    }

    final outcome = await creationMethod!.create(
      currentForm!.method,
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
      NewWalletInfoPage.preShowSeedPage(L, T),
      NewWalletInfoPage.writeDownNotice(
        L,
        T,
        text: outcome.wallet!.seed,
        title: outcome.wallet!.walletName,
      ),
      if (outcome.wallet!.passphrase.isNotEmpty)
        NewWalletInfoPage.writeDownNotice(
          L,
          T,
          text: outcome.wallet!.passphrase,
          title: L.wallet_passphrase,
        ),
      NewWalletInfoPage.seedWrittenDown(
        L,
        T,
        wallet: outcome.wallet!,
        nextCallback: () => completeSetup(outcome.wallet!),
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
    if (screenName == suggestedTitle) return;
    screenName = suggestedTitle ?? screenNameOriginal;
  }
}
