import 'package:cupcake/utils/types.dart';
import 'package:cupcake/view_model/wallet_setup_error_title.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restore setup errors use the restore title', () {
    expect(
      walletSetupErrorTitle(
        createTitle: 'Create Wallet',
        restoreTitle: 'Restore wallet',
        screenMethod: CreateMethod.restore,
        formMethod: CreateMethod.restore,
      ),
      'Restore wallet',
    );
    expect(
      walletSetupErrorTitle(
        createTitle: 'Create Wallet',
        restoreTitle: 'Restore wallet',
        screenMethod: null,
        formMethod: CreateMethod.restore,
      ),
      'Restore wallet',
    );
  });

  test('create setup errors keep the create title', () {
    expect(
      walletSetupErrorTitle(
        createTitle: 'Create Wallet',
        restoreTitle: 'Restore wallet',
        screenMethod: CreateMethod.create,
        formMethod: CreateMethod.create,
      ),
      'Create Wallet',
    );
  });
}
