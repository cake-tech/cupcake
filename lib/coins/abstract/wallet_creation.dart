// creation = any action that results in new wallet being created, be that restore or generate
// To unify the process of wallet creation we provide multiple "generators".
// There is one class that defines inputs (FormElement)
// And multiple WalletCreation classes
// When creating wallet heuristic are being applied to see which creation method will be used,
// it is entirely possible for one input of restore/creation form to have multiple outputs,

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';

abstract class WalletCreation {
  Coin get coin;
  Future<CreationOutcome?> create(
    @Deprecated("Shouldn't depend on this") final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  );
  Map<String, WalletCreationForm> createMethods(final CreateMethod createMethod);

  // wipe function clears all details from WalletCreation form
  void wipe();
}

class WalletCreationForm {
  WalletCreationForm({
    required this.method,
    required this.form,
  });
  CreateMethod method;
  List<FormElement> form;
}

// No need for CreationMethod to exist but it makes sure that we follow some internal structure
// of wallet generation.
abstract class CreationMethod {
  CreationMethod();

  Future<CreationOutcome> create();
}

class CreationOutcome {
  CreationOutcome({
    required this.success,
    required this.method,
    this.wallet,
    this.message,
  }) :
        // We must provide a detailed feedback regarding why creation failed
        assert(
          (success == false && message != null && message.isNotEmpty) || success,
        );
  final bool success;
  final CoinWallet? wallet;
  final CreateMethod method;
  final String? message;
}
