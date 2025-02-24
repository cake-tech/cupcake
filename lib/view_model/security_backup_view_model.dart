import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/abstract.dart';

part 'security_backup_view_model.g.dart';

@GenerateRebuild()
class SecurityBackupViewModel extends ViewModel {
  SecurityBackupViewModel({required this.wallet});

  @override
  String get screenName => L.security_and_backup;

  @RebuildOnChange()
  bool $isLocked = true;

  late List<FormElement> form = [
    PinFormElement(
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
      showNumboard: true,
      onConfirm: () async {
        try {
          await form.first.value;
        } catch (e) {
          print(e);
        }
        isLocked = false;
      },
      errorHandler: errorHandler,
    ),
  ];

  CoinWallet wallet;
}
