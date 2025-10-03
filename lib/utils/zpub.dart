import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';

String convertXpubToZpub(final String xpub) {
  try {
    final decoded = Base58Decoder.checkDecode(xpub);

    if (decoded.length < 4) {
      throw ArgumentError('Invalid extended public key length');
    }

    final versionBytes = decoded.sublist(0, 4);
    final xpubVersionBytes = [0x04, 0x88, 0xb2, 0x1e]; // xpub mainnet version
    final tpubVersionBytes = [0x04, 0x35, 0x87, 0xcf]; // tpub testnet version

    final bool isXpub = listEquals(versionBytes, xpubVersionBytes);
    final bool isTpub = listEquals(versionBytes, tpubVersionBytes);

    if (!isXpub && !isTpub) {
      return xpub;
    }

    final zpubVersionBytes = isXpub
        ? [0x04, 0xb2, 0x47, 0x46]
        : // zpub mainnet
        [0x04, 0x5f, 0x1c, 0xf6]; // vpub testnet

    final newExtendedKey = Uint8List.fromList([
      ...zpubVersionBytes,
      ...decoded.sublist(4),
    ]);

    return Base58Encoder.checkEncode(newExtendedKey);
  } catch (e) {
    throw ArgumentError('Failed to convert xpub to zpub: $e');
  }
}

bool listEquals<T>(final List<T> a, final List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
