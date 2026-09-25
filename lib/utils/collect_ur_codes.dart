/// Collects `ur:` parts from [rawValues], appending new ones onto [existing].
///
/// Non-ur and null values are ignored. A duplicate is skipped so later parts
/// in the same capture are still recorded.
List<String> collectUrCodes(
  final List<String> existing,
  final Iterable<String?> rawValues,
) {
  var codes = List<String>.from(existing);
  for (final rawValue in rawValues) {
    if (rawValue == null || !rawValue.startsWith('ur:')) {
      continue;
    }
    if (codes.contains(rawValue)) {
      continue;
    }
    codes = [...codes, rawValue];
  }
  return codes;
}
