import 'package:cupcake/coins/abstract/coin_wallet.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';

class SecurityBackupViewModel extends ViewModel {
  SecurityBackupViewModel({required this.wallet});

  @override
  // TODO: implement screenName
  String get screenName => L.security_and_backup;

  bool isLocked = true;

  late List<FormElement> form = [
    PinFormElement(
        label: "Wallet password",
        password: true,
        valueOutcome: FlutterSecureStorageValueOutcome(
          "secure.wallet_password",
          canWrite: false,
          verifyMatching: true,
        ),
        validator: (String? input) {
          if (input == null) return L.warning_input_cannot_be_null;
          if (input == "") return L.warning_input_cannot_be_empty;
          if (input.length < 4) {
            return L.warning_password_too_short;
          }
          return null;
        },
        showNumboard: true,
        onConfirm: (BuildContext context) async {
          try {
            await form.first.value;
          } catch (e) {
            print(e);
          }
          isLocked = false;
          markNeedsBuild();
        })
  ];

  CoinWallet wallet;

  void titleUpdate(String? suggestedTitle) {}
}
