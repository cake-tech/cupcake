import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
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
          await form.first.value;

          isLocked = false;
          markNeedsBuild();
        })
  ];

  CoinWallet wallet;
}
