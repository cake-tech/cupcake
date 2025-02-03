import 'dart:async';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/coins/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/plain_value_outcome.dart';
import 'package:cupcake/utils/form/single_choice_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/null_if_empty.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/new_wallet_info_view_model.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CreateWalletViewModel extends ViewModel {
  CreateWalletViewModel({
    required this.createMethod,
    required this.needsPasswordConfirm,
  });

  final CreateMethod createMethod;

  bool isPinSet = false;
  bool showExtra = false;

  @override
  late String screenName = screenNameOriginal;

  String get screenNameOriginal => switch (createMethod) {
        CreateMethod.any => L.create_wallet,
        CreateMethod.create => L.create_wallet,
        CreateMethod.restore => L.restore_wallet,
      };

  List<Coin> get coins => walletCoins;

  bool isCreate = true;

  bool get hasAdvancedOptions {
    if (currentForm == null) return false;
    for (final elm in currentForm!) {
      if (elm is StringFormElement) {
        if (elm.isExtra) return true;
      }
    }
    return false;
  }

  void toggleAdvancedOptions() {
    print("toggling");
    showExtra = !showExtra;
    markNeedsBuild();
  }

  late Coin? selectedCoin = () {
    if (coins.length == 1) {
      return coins[0];
    }
    return null;
  }();

  late StringFormElement walletName = StringFormElement(
    L.wallet_name,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
    randomNameGenerator: true,
  );

  late SingleChoiceFormElement walletSeedType = SingleChoiceFormElement(
    title: L.seed_type,
    elements: [
      L.seed_type_polyseed,
      L.seed_type_legacy,
    ],
  );

  late PinFormElement walletPasswordInitial = PinFormElement(
    label: L.wallet_password,
    password: true,
    valueOutcome: PlainValueOutcome(),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
      }
      return null;
    },
  );

  late PinFormElement walletPassword = PinFormElement(
    label:
        (needsPasswordConfirm) ? L.wallet_password_repeat : L.wallet_password,
    password: true,
    valueOutcome: FlutterSecureStorageValueOutcome(
      "secure.wallet_password",
      canWrite: true,
      verifyMatching: true,
    ),
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.length < 4) {
        return L.warning_password_too_short;
      }
      if (input != walletPasswordInitial.ctrl.text && needsPasswordConfirm) {
        return L.password_doesnt_match;
      }
      return null;
    },
  );

  late StringFormElement seed = StringFormElement(
    L.wallet_seed,
    password: false,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      if (input.split(" ").length != 16 && input.split(" ").length != 25) {
        return L.warning_seed_incorrect_length;
      }
      return null;
    },
  );

  late StringFormElement walletAddress = StringFormElement(
    L.primary_address_label,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement secretSpendKey = StringFormElement(
    L.secret_spend_key,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement secretViewKey = StringFormElement(
    L.secret_view_key,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement restoreHeight = StringFormElement(
    L.restore_height,
    password: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late StringFormElement seedOffset = StringFormElement(
    L.seed_offset,
    password: true,
    isExtra: true,
    validator: (String? input) {
      if (input == null) return L.warning_input_cannot_be_null;
      if (input == "") return L.warning_input_cannot_be_empty;
      return null;
    },
  );

  late List<FormElement>? currentForm = () {
    if (createMethods.length == 1) {
      return createMethods[createMethods.keys.first];
    }
    return null;
  }();

  Map<String, List<FormElement>> get createMethods => {
        if ([CreateMethod.any, CreateMethod.create].contains(createMethod))
          L.option_create_new_wallet: _createForm,
        if ([CreateMethod.any, CreateMethod.restore]
            .contains(createMethod)) ...{
          L.option_create_seed: _restoreSeedForm,
          L.option_create_keys: _restoreFormKeysForm,
        },
      };

  bool needsPasswordConfirm;

  late final List<FormElement> _createForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    walletSeedType,
    seedOffset
  ];

  late final List<FormElement> _restoreSeedForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    seed,
    seedOffset
  ];

  late final List<FormElement> _restoreFormKeysForm = [
    if (needsPasswordConfirm) walletPasswordInitial,
    walletPassword,
    walletName,
    walletAddress,
    secretSpendKey,
    secretViewKey,
  ];

  Future<void> createWallet(BuildContext context) async {
    if (selectedCoin == null) throw Exception("selectedCoin is null");
    if ((await walletName.value).isEmpty) {
      throw Exception(L.warning_input_cannot_be_empty);
    }
    print(currentForm == _createForm);
    final cw = await selectedCoin!.createNewWallet(
      await walletName.value,
      await walletPassword.value,
      primaryAddress: (await walletAddress.value).nullIfEmpty(),
      createWallet: (currentForm == _createForm),
      seed: (await seed.value).nullIfEmpty(),
      restoreHeight: int.tryParse(await restoreHeight.value),
      viewKey: (await secretViewKey.value).nullIfEmpty(),
      spendKey: (await secretSpendKey.value).nullIfEmpty(),
      seedOffsetOrEncryption: (await seedOffset.value).nullIfEmpty(),
    );

    final List<NewWalletInfoPage> pages = [
      NewWalletInfoPage(
        topText: L.important,
        topAction: null,
        topActionText: null,
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.nextPage,
            function: null,
            text: Text(
              L.understand_show_seed,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            L.important_seed_backup_info(
                "16 word"), // TODO: translate it better?
            textAlign: TextAlign.center,
          ),
        ],
      ),
      NewWalletInfoPage(
        topText: L.seed,
        topAction: seedOffset.ctrl.text.isNotEmpty
            ? null
            : () {
                CupcakeConfig.instance.initialSetupComplete = true;
                CupcakeConfig.instance.save();
                WalletHome(coinWallet: cw).push(context);
              },
        topActionText: Text(L.next),
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Share.share(cw.seed);
            },
            text: Text(
              L.save,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Clipboard.setData(ClipboardData(text: cw.seed));
            },
            text: Text(
              L.copy,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            cw.walletName,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            "${cw.seed}\n\n\n\n${L.write_down_notice}",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      if (seedOffset.ctrl.text.isNotEmpty)
        NewWalletInfoPage(
          topText: L.wallet_passphrase,
          topAction: () {
            CupcakeConfig.instance.initialSetupComplete = true;
            CupcakeConfig.instance.save();
            WalletHome(coinWallet: cw).push(context);
          },
          topActionText: Text(L.next),
          lottieAnimation: Assets.shield.lottie(),
          actions: [
            NewWalletAction(
              type: NewWalletActionType.function,
              function: () {
                Share.share(cw.seed);
              },
              text: Text(
                L.save,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
            NewWalletAction(
              type: NewWalletActionType.function,
              function: () {
                Clipboard.setData(ClipboardData(text: cw.seed));
              },
              text: Text(
                L.copy,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
          ],
          texts: [
            Text(
              cw.walletName,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              "${seedOffset.value}\n\n\n\n${L.write_down_notice}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
    ];
    if (!context.mounted) {
      throw Exception("context is not mounted, unable to show next screen");
    }
    if (currentForm != _createForm) {
      WalletHome(coinWallet: cw).push(context);
    } else {
      NewWalletInfoScreen(
        pages: pages,
      ).push(context);
    }
  }

  void titleUpdate(String? suggestedTitle) async {
    await Future.delayed(Duration.zero); // don't do it on build();
    screenName = suggestedTitle ?? screenNameOriginal;
    markNeedsBuild();
  }
}
