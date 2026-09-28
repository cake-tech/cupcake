import 'package:path/path.dart' as p;

/// Normalized wallet path under [basePath], or null when [walletName] leaves it.
///
/// A trailing separator is required, so a sibling like `btc-evil` is not
/// treated as inside `btc`. The directory itself is not a wallet path.
String? pathInsideWalletDirectory(final String basePath, final String walletName) {
  final base = p.normalize(basePath);
  final walletPath = p.normalize(p.join(base, walletName));
  if (walletPath == base) return null;
  final prefix = base.endsWith(p.separator) ? base : '$base${p.separator}';
  if (!walletPath.startsWith(prefix)) return null;
  return walletPath;
}
