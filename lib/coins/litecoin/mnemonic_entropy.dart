import 'dart:math';
import 'dart:typed_data';

/// Entropy bytes for a new Litecoin mnemonic.
///
/// Draws each byte from the full 0..255 range. The bip39 default stops at 254.
Uint8List mnemonicEntropyBytes(
  final int size, {
  final int Function(int max)? nextInt,
}) {
  final draw = nextInt ?? Random.secure().nextInt;
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = draw(256);
  }
  return bytes;
}

/// `randomBytes` callback for `bip39.generateMnemonic`.
Uint8List litecoinMnemonicEntropy(final int size) => mnemonicEntropyBytes(size);
