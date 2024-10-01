import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

late String baseStoragePath;

Future<void> initializeBaseStoragePath() async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    final dataDir = await getApplicationDocumentsDirectory();
    baseStoragePath = path.join(dataDir.path, "cupcake");
    final dir = Directory(baseStoragePath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return;
  }
  throw UnimplementedError("filesystem.dart is not prepared for your platform");
}
