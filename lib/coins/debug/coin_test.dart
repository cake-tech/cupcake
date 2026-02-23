typedef TestLog = void Function(String line);

class CoinTestCase {
  CoinTestCase(this.name, this.body);
  final String name;
  final Future<void> Function(TestLog log) body;
}

class TestFailure implements Exception {
  TestFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class TestSkipped implements Exception {
  TestSkipped(this.reason);
  final String reason;

  @override
  String toString() => reason;
}

void expectTrue(final bool value, final String what) {
  if (!value) throw TestFailure(what);
}

void expectEquals(final Object? actual, final Object? expected, final String what) {
  if (!_deepEquals(actual, expected)) {
    throw TestFailure("$what\n  expected: $expected\n  actual:   $actual");
  }
}

bool _deepEquals(final Object? a, final Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

class CoinTestResults {
  int passed = 0;
  int failed = 0;
  int skipped = 0;

  bool get ok => failed == 0;

  @override
  String toString() => "$passed passed, $failed failed, $skipped skipped";
}

Future<void> runCoinTests(
  final List<CoinTestCase> cases,
  final TestLog log,
  final CoinTestResults results,
) async {
  for (final testCase in cases) {
    final stopwatch = Stopwatch()..start();
    try {
      await testCase.body(log);
      results.passed++;
      log("PASS ${testCase.name} (${stopwatch.elapsedMilliseconds}ms)");
    } on TestSkipped catch (e) {
      results.skipped++;
      log("SKIP ${testCase.name}: $e");
    } catch (e, s) {
      results.failed++;
      log("FAIL ${testCase.name} (${stopwatch.elapsedMilliseconds}ms)\n$e");
      if (e is! TestFailure) log(s.toString());
    }
    await Future<void>.delayed(Duration.zero);
  }
}
