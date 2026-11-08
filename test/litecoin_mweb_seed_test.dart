import 'package:cupcake/coins/litecoin/mweb_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('litecoin mweb seed changes when the passphrase changes', () {
    const mnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

    final without = litecoinMwebSeed(mnemonic, '');
    final withPassphrase = litecoinMwebSeed(mnemonic, 'secret');

    expect(withPassphrase, isNot(without));
  });
}
