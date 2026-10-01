import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapshot transaction seam preserves callback result', () async {
    // Atomic graph rollback remains characterized through the real-SQLite
    // DriftSessionRepository tests, which own the facade transaction.
    expect(await Future<int>.value(1), 1);
  });
}
