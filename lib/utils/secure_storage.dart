import 'package:cupcake/utils/secure_storage_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final FlutterSecureStorage secureStorage =
    FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<void> setWalletPin(final String password) async {
  final pin = await secureStorage.read(key: SecureStorageKey.pin);
  if (pin != null) throw Exception("${SecureStorageKey.pin} is not null");
  await secureStorage.write(key: SecureStorageKey.pin, value: password);
}

Future<bool> verifyWalletPin(final String password) async {
  final pin = await secureStorage.read(key: SecureStorageKey.pin);
  if (pin == null) throw Exception("${SecureStorageKey.pin} is null");
  if (pin == password) return true;
  return false;
}
