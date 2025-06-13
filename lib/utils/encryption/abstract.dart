import 'dart:typed_data';

abstract class Encryption {
  Uint8List encryptBytes(final Uint8List plaintext, final String password);
  Uint8List decryptBytes(final Uint8List ciphertext, final String password);
  Uint8List encryptString(final String plaintext, final String password);
  String decryptString(final Uint8List ciphertext, final String password);
}
