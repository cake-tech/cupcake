import 'package:flutter/services.dart';

Future<String?> getSigningKey() async {
  const platform = MethodChannel('com.cakewallet.cup_cake/key');
  try {
    final String result = await platform.invokeMethod('getSigningKey');
    return result;
  } on PlatformException catch (e) {
    print("Failed to get signing key: '${e.message}'.");
    return null;
  }
}
