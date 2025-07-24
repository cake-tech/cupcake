import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/flutter_secure_storage_value_outcome.dart';
import 'package:cupcake/utils/form/pin_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:mobx/mobx.dart';

part 'security_backup_view_model.g.dart';

class SecurityBackupViewModel = SecurityBackupViewModelBase with _$SecurityBackupViewModel;

abstract class SecurityBackupViewModelBase extends ViewModel with Store {
  SecurityBackupViewModelBase({required this.wallet});

  @override
  String get screenName => L.security_and_backup;

  @observable
  bool isLocked = true;

  @observable
  late FormBuilderViewModel formBuilderViewModel = FormBuilderViewModel(
    formElements: form,
    scaffoldContext: c!,
    isPinSet: !isLocked,
    toggleIsPinSet: (final bool val) {
      isLocked = val;
    },
  );

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
      enableBiometric: false,
    ),
  ];

  final CoinWallet wallet;
}
