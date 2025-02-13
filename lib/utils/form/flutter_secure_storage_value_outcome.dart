import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_value_outcome.dart';
import 'package:cupcake/utils/secure_storage.dart';

class FlutterSecureStorageValueOutcome implements ValueOutcome {
  FlutterSecureStorageValueOutcome(this.key,
      {required this.canWrite, required this.verifyMatching});

  final String key;
  final bool canWrite;
  final bool verifyMatching;

  @override
  Future<void> encode(final String input) async {
    final List<int> bytes = utf8.encode(input);
    final Digest sha512Hash = sha512.convert(bytes);
    var valInput = await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (valInput == null) {
      await secureStorage.write(
          key: "FlutterSecureStorageValueOutcome._$key", value: sha512Hash.toString());
      valInput = await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    }
    if (sha512Hash.toString() != valInput && verifyMatching) {
      throw Exception("Input doesn't match the secure element value");
    }

    final input_ = await secureStorage.read(key: key);
    // Do not update secret if it is already set.
    if (input_ != null) {
      return;
    }
    if (!canWrite) {
      if (CupcakeConfig.instance.debug) {
        throw Exception("DEBUG_ONLY: canWrite is false but we tried to flush the value");
      }
      return;
    }
    final random = Random.secure();
    final values = List<int>.generate(64, (final i) => random.nextInt(256));
    final pass = base64Url.encode(values);
    await secureStorage.write(key: key, value: pass);
    return;
  }

  @override
  Future<String> decode(final String output) async {
    final List<int> bytes = utf8.encode(output);
    final Digest sha512Hash = sha512.convert(bytes);
    final valInput = await secureStorage.read(key: "FlutterSecureStorageValueOutcome._$key");
    if (sha512Hash.toString() != valInput && verifyMatching) {
      throw Exception("Input doesn't match the secure element value");
    }
    final input = await secureStorage.read(key: key);
    if (input == null) {
      throw Exception("no secure storage $key found");
    }
    return "$input/$output";
  }

  @override
  String get uniqueId => key;
}
