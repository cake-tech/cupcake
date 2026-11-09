import 'package:cupcake/coins/litecoin/mnemonic_entropy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('litecoin mnemonic entropy can use every byte value', () {
    var bound = 0;
    final bytes = mnemonicEntropyBytes(
      1,
      nextInt: (final max) {
        bound = max;
        return max - 1;
      },
    );

    expect(bound, 256);
    expect(bytes.single, 255);
  });
}
