import 'package:cupcake/utils/wallet_directory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallet path rejects a name that leaves the directory', () {
    expect(pathInsideWalletDirectory('/wallets/btc', '../btc-evil'), isNull);
    expect(pathInsideWalletDirectory('/wallets/btc', '../btc'), isNull);
    expect(pathInsideWalletDirectory('/wallets/ltc', '../btc/evil'), isNull);
  });

  test('wallet path keeps a plain name', () {
    expect(
      pathInsideWalletDirectory('/wallets/btc', 'savings'),
      '/wallets/btc/savings',
    );
  });
}
