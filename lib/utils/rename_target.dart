import 'package:path/path.dart' as p;

/// Whether [newName] stays inside [basePath].
///
/// A name with a slash, or one that normalizes out of [basePath], is rejected.
bool renameNameStaysInDirectory(final String basePath, final String newName) {
  if (newName.isEmpty || newName.contains('/') || newName.contains('\\')) {
    return false;
  }
  final base = p.normalize(basePath);
  final target = p.normalize(p.join(base, newName));
  if (target == base) return false;
  final prefix = base.endsWith(p.separator) ? base : '$base${p.separator}';
  return target.startsWith(prefix);
}
