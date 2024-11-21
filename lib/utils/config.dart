import 'dart:convert';
import 'dart:io';

import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class CupcakeConfig {
  CupcakeConfig({
    required this.lastWallet,
    required this.initialSetupComplete,
    required this.walletMigrationLevel,
    required this.msForQrCode,
    required this.maxFragmentLength,
    required this.walletSort,
    required this.debug,
    required this.oldSecureStorage,
  });
  CoinWalletInfo? lastWallet;
  bool initialSetupComplete;
  int walletMigrationLevel;
  int msForQrCode;
  int maxFragmentLength;
  int walletSort;
  bool debug;
  Map<String, dynamic> oldSecureStorage;

  factory CupcakeConfig.fromJson(Map<String, dynamic> json) {
    return CupcakeConfig(
      lastWallet: CoinWalletInfo.fromJson(json['lastWallet']),
      initialSetupComplete: json['initialSetupComplete'] ?? false,
      walletMigrationLevel: json['walletMigrationLevel'] ?? 0,
      msForQrCode: json['msForQrCode'] ?? 1000 ~/ 3.5,
      maxFragmentLength: json['maxFragmentLength'] ?? 130,
      walletSort: json['walletSort'] ?? 0,
      debug: json['debug'] ?? false,
      oldSecureStorage: json['oldSecureStorage'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastWallet': lastWallet,
      'initialSetupComplete': initialSetupComplete,
      'walletMigrationLevel': walletMigrationLevel,
      'msForQrCode': msForQrCode,
      'maxFragmentLength': maxFragmentLength,
      'walletSort': walletSort,
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
