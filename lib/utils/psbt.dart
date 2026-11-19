import 'dart:typed_data';

/// Warnings to show before an offline signer confirms a PSBT.
///
/// The fee can only be checked when each input carries the full previous
/// transaction. A sighash other than SIGHASH_ALL or SIGHASH_DEFAULT does not
/// commit to the outputs shown on the confirmation screen. SIGHASH_DEFAULT
/// is the Taproot default and commits to every input and output, the same
/// way SIGHASH_ALL does.
List<String> psbtConfirmationWarnings(final List<int> psbtBytes) {
  try {
    final (sighashes, feeOk) = _inspect(Uint8List.fromList(psbtBytes));
    return [
      if (!feeOk)
        'The fee shown cannot be independently verified. '
            'Input amounts come from the wallet that created this PSBT and may not '
            'match what you actually pay.',
      if (sighashes.isNotEmpty)
        'This transaction uses a non-standard signature type '
            '(${sighashes.map(_sighashName).join(', ')}) on '
            '${sighashes.length} input${sighashes.length == 1 ? '' : 's'}. '
            'The signature may not commit to the outputs shown below. '
            'Only continue if you trust the wallet that created this PSBT.',
    ];
  } catch (_) {
    return const [
      'Could not verify this PSBT. Only continue if you trust the wallet that created it.',
    ];
  }
}

// Non-ALL sighash types in input order, and whether the fee can be checked.
(List<int>, bool) _inspect(final Uint8List bytes) {
  final r = _R(bytes);
  if (bytes.length < 5 ||
      bytes[0] != 0x70 ||
      bytes[1] != 0x73 ||
      bytes[2] != 0x62 ||
      bytes[3] != 0x74 ||
      bytes[4] != 0xff) {
    throw FormatException('bad magic');
  }
  r.i = 5;

  final global = <int, Uint8List>{};
  while (_entry(global, r)) {}

  final int nIn;
  final int nOut;
  if (global[0x00] case final tx?) {
    (nIn, nOut) = _txCounts(tx);
  } else {
    nIn = _R(global[0x04]!).varint();
    nOut = _R(global[0x05]!).varint();
  }
  if (nIn <= 0) throw FormatException('no inputs');

  final sighashes = <int>[];
  var feeOk = true;
  for (var i = 0; i < nIn; i++) {
    final input = <int, Uint8List>{};
    while (_entry(input, r)) {}
    if (!input.containsKey(0x00)) feeOk = false;
    final raw = input[0x03];
    if (raw != null && raw.length == 4) {
      final type = ByteData.sublistView(raw).getUint32(0, Endian.little);
      // 0x00 is SIGHASH_DEFAULT. It binds every input and output.
      if (type != 0x01 && type != 0x00) sighashes.add(type);
    }
  }
  for (var i = 0; i < nOut; i++) {
    while (_entry(null, r)) {}
  }
  return (sighashes, feeOk);
}

bool _entry(final Map<int, Uint8List>? map, final _R r) {
  final keyLen = r.varint();
  if (keyLen == 0) return false;
  final keyType = r.u8();
  final keyData = r.take(keyLen - 1);
  final value = r.take(r.varint());
  if (map != null && keyData.isEmpty) map[keyType] = value;
  return true;
}

(int, int) _txCounts(final Uint8List tx) {
  final r = _R(tx)..i = 4;
  if (r.left > 0 && r.data[r.i] == 0x00) {
    r.u8();
    if (r.u8() != 0x01) throw FormatException('bad segwit marker');
  }
  final vin = r.varint();
  for (var i = 0; i < vin; i++) {
    r.take(36);
    r.take(r.varint());
    r.take(4);
  }
  return (vin, r.varint());
}

String _sighashName(final int type) {
  final base = switch (type & 0x1f) {
    0x00 => 'SIGHASH_DEFAULT',
    0x01 => 'SIGHASH_ALL',
    0x02 => 'SIGHASH_NONE',
    0x03 => 'SIGHASH_SINGLE',
    _ => 'SIGHASH_$type',
  };
  return (type & 0x80) != 0 ? '$base|ANYONECANPAY' : base;
}

class _R {
  _R(this.data);
  final Uint8List data;
  int i = 0;

  int get left => data.length - i;
  int u8() => data[i++];
  Uint8List take(final int n) {
    final out = Uint8List.sublistView(data, i, i + n);
    i += n;
    return out;
  }

  int varint() {
    final b = u8();
    if (b < 0xfd) return b;
    if (b == 0xfd) return u8() | (u8() << 8);
    if (b == 0xfe) return u8() | (u8() << 8) | (u8() << 16) | (u8() << 24);
    throw FormatException('varint too large');
  }
}
