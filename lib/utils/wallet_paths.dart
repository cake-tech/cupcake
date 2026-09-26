import 'package:path/path.dart' as p;

/// Path stored on the wallet after a rename. Keeps the wallet directory.
String pathAfterRename(final String currentPath, final String newName) {
  return p.join(p.dirname(currentPath), newName);
}

/// Litecoin stores the wallet in the `.keys` file, not the bare name.
String litecoinRenameSource(final String walletPath) {
  return '$walletPath.keys';
}

/// Path used to notice that [newName] is already taken.
String renameCollisionPath(
  final String basePath,
  final String newName, {
  required final bool keysFile,
}) {
  final name = keysFile ? '$newName.keys' : newName;
  return p.join(basePath, name);
}
