import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:path/path.dart' as p;
import 'package:mobx/mobx.dart';

part 'wallet_edit_view_model.g.dart';

class WalletEditViewModel = WalletEditViewModelBase with _$WalletEditViewModel;

abstract class WalletEditViewModelBase extends ViewModel with Store {
  WalletEditViewModelBase({
    required this.walletInfo,
  });

  final CoinWalletInfo walletInfo;

  @observable
  late FormBuilderViewModel formBuilderViewModel = FormBuilderViewModel(
    formElements: form,
    scaffoldContext: c!,
    isPinSet: false,
    toggleIsPinSet: (final bool val) {
      // isPinSet = val;
    },
  );

  late StringFormElement walletName = StringFormElement(
    L.wallet_name,
    initialText: p.basename(walletInfo.walletName),
    validator: nonEmptyValidator(L),
    randomNameGenerator: true,
    errorHandler: errorHandler,
    canPaste: false,
  );

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
    showNumboard: false,
    errorHandler: errorHandler,
    enableBiometric: false,
  );

  late final List<FormElement> form = [
    walletName,
    walletPassword,
  ];

  @override
  String get screenName => L.edit_wallet;

  Future<bool> deleteWallet() {
    return callThrowable(
      () async {
        if (!(await walletInfo.checkWalletPassword(await walletPassword.value))) {
          throw Exception(L.invalid_password);
        }
        await walletInfo.deleteWallet();
        if (!mounted) return;
        Navigator.of(c!).pop();
      },
      L.delete_wallet,
    );
  }

  Future<bool> renameWallet() {
    return callThrowable(
      () async {
        if (!(await walletInfo.checkWalletPassword(await walletPassword.value))) {
          throw Exception(L.invalid_password);
        }
        if ((await walletName.value).isEmpty) {
          throw Exception(L.error_wallet_name_empty);
        }
        await walletInfo.renameWallet(await walletName.value);
        if (!mounted) return;
        Navigator.of(c!).pop();
      },
      L.rename_wallet,
    );
  }
}
