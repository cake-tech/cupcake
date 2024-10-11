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
  });
  CoinWalletInfo? lastWallet;
  bool initialSetupComplete;
  int walletMigrationLevel;

  factory CupcakeConfig.fromJson(Map<String, dynamic> json) {
    return CupcakeConfig(
      lastWallet: CoinWalletInfo.fromJson(json['lastWallet']),
      initialSetupComplete: json['initialSetupComplete'] ?? false,
      walletMigrationLevel: json['walletMigrationLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastWallet': lastWallet,
      'initialSetupComplete': initialSetupComplete,
      'walletMigrationLevel': walletMigrationLevel,
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
