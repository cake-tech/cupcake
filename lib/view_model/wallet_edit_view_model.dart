import 'dart:async';

import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/utils/alerts/widget.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/cupertino.dart';
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
    showAlertWidget(
      context: c!,
      title: L.confirm,
      showOk: false,
      body: [
        Text(
          L.delete_confirm_notice,
          textAlign: TextAlign.center,
          style: TextStyle(color: T.colorScheme.onSurface, fontSize: 16),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: LongPrimaryButton(
                  padding: EdgeInsets.zero,
                  backgroundColorOverride: WidgetStateProperty.all(T.colorScheme.surfaceContainer),
                  textColor: T.colorScheme.onSurface,
                  onPressed: () => Navigator.of(c!).pop(),
                  text: L.cancel,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: LongPrimaryButton(
                  padding: EdgeInsets.zero,
                  backgroundColorOverride: WidgetStateProperty.all(T.colorScheme.onError),
                  textColor: T.colorScheme.onSurface,
                  onPressed: _deleteWallet,
                  text: L.delete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Future.value(true);
  }

  Future<bool> _deleteWallet() {
    return callThrowable(
      () async {
        if (!(await walletInfo.checkWalletPassword(await walletPassword.value))) {
          throw Exception(L.invalid_password);
        }
        await walletInfo.deleteWallet();
        if (!mounted) return;
        unawaited(
          HomeScreen(
            openLastWallet: false,
          ).pushReplacement(c!),
        );
        await walletPassword.clear();
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
        unawaited(
          HomeScreen(
            openLastWallet: false,
          ).pushReplacement(c!),
        );
        await walletPassword.clear();
      },
      L.rename_wallet,
    );
  }
}
