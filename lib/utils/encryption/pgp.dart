import 'dart:convert';
import 'dart:typed_data';

import 'package:cupcake/utils/encryption/abstract.dart';
import 'package:dart_pg/dart_pg.dart';

class PgpEncryption implements Encryption {
  @override
  Uint8List decryptBytes(final Uint8List ciphertext, final String password) {
    final armored = utf8.decode(ciphertext);
    final literalMessage = OpenPGP.decrypt(
      armored,
      passwords: [password],
    );
    final literalData = literalMessage.literalData;
    return literalData.binary;
  }

  @override
  String decryptString(final Uint8List ciphertext, final String password) {
    final bytes = decryptBytes(ciphertext, password);
    return utf8.decode(bytes);
  }

  @override
  Uint8List encryptBytes(final Uint8List plaintext, final String password) {
    final encryptedMessage = OpenPGP.encryptBinaryData(
      plaintext,
      passwords: [password],
    );
    final armored = encryptedMessage.armor();
    return utf8.encode(armored);
  }

  @override
  Uint8List encryptString(final String plaintext, final String password) {
    return encryptBytes(utf8.encode(plaintext), password);
  }
}
