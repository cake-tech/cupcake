import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final FlutterSecureStorage secureStorage =
    FlutterSecureStorage(aOptions: _getAndroidOptions());

class SecureStorageKey {
  static String pin = "secret.pin";
}

Future<void> setWalletPin(String password) async {
  final pin = await secureStorage.read(key: SecureStorageKey.pin);
  if (pin != null) throw Exception("${SecureStorageKey.pin} is not null");
  await secureStorage.write(key: SecureStorageKey.pin, value: password);
}

Future<bool> verifyWalletPin(String password) async {
  final pin = await secureStorage.read(key: SecureStorageKey.pin);
  if (pin == null) throw Exception("${SecureStorageKey.pin} is null");
  if (pin == password) return true;
  return false;
}
