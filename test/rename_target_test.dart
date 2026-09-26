import 'package:cupcake/utils/rename_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rename rejects a name that leaves the wallet directory', () {
    expect(renameNameStaysInDirectory('/wallets/btc', '../../tmp/x'), isFalse);
    expect(renameNameStaysInDirectory('/wallets/btc', '../btc2'), isFalse);
    expect(renameNameStaysInDirectory('/wallets/btc', 'nested/name'), isFalse);
  });

  test('rename allows a plain wallet name', () {
    expect(renameNameStaysInDirectory('/wallets/btc', 'savings'), isTrue);
  });
}
