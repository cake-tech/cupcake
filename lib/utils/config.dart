import 'dart:convert';
import 'dart:io';

import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/filesystem.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class CupcakeConfig {
  CupcakeConfig({
    required this.lastWallet,
    required this.initialSetupComplete,
    required this.walletMigrationLevel,
    required this.msForQrCode,
    required this.maxFragmentLength,
    required this.debug,
  });
  CoinWalletInfo? lastWallet;
  bool initialSetupComplete;
  int walletMigrationLevel;
  int msForQrCode;
  int maxFragmentLength;
  bool debug;

  factory CupcakeConfig.fromJson(Map<String, dynamic> json) {
    return CupcakeConfig(
      lastWallet: CoinWalletInfo.fromJson(json['lastWallet']),
      initialSetupComplete: json['initialSetupComplete'] ?? false,
      walletMigrationLevel: json['walletMigrationLevel'] ?? 0,
      msForQrCode: json['msForQrCode'] ?? 1000 ~/ 3.5,
      maxFragmentLength: json['maxFragmentLength'] ?? 130,
      debug: json['debug'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastWallet': lastWallet,
      'initialSetupComplete': initialSetupComplete,
      'walletMigrationLevel': walletMigrationLevel,
      'msForQrCode': msForQrCode,
      'maxFragmentLength': maxFragmentLength,
      'debug': debug,
    };
  }

  void save() {
    File(configPath).writeAsStringSync(json.encode(toJson()));
  }
}

final configPath = p.join(baseStoragePath, "config.json");
final config = (() {
  try {
    return CupcakeConfig.fromJson(
      json.decode(
        File(configPath).readAsStringSync(),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print("failed getting wallet config: $e");
      print("don't worry tho - I'll create config with defaults");
    }
    return CupcakeConfig.fromJson({});
  }
})();
