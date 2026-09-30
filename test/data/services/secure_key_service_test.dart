import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/services/database_key.dart';
import 'package:vulcan_fitness/data/services/secure_key_service.dart';

void main() {
  group('DatabaseKey', () {
    test('accepts exactly 32 bytes of lowercase hexadecimal', () {
      final result = DatabaseKey.fromHex('ab' * 32);

      expect(result, isA<Ok<DatabaseKey>>());
      expect((result as Ok<DatabaseKey>).value.toString(), isNot('ab' * 32));
    });

    test('rejects malformed values without revealing them', () {
      final result = DatabaseKey.fromHex('ABC');

      expect(result, isA<Err<DatabaseKey>>());
      expect((result as Err<DatabaseKey>).failure, isA<EncryptionFailure>());
      expect(result.failure.message, isNot(contains('ABC')));
    });
  });

  group('SecureKeyService', () {
    test('creates, writes, and verifies a new key', () async {
      final storage = FakeStorage();
      final service = SecureKeyService(
        storage: storage,
        entropy: FixedEntropy(List<int>.generate(32, (index) => index)),
      );

      final result = await service.loadOrCreate(databaseExists: false);

      expect(result, isA<Ok<DatabaseKey>>());
      expect(storage.writes, 1);
      final expected = List<String>.generate(
        32,
        (index) => index.toRadixString(16).padLeft(2, '0'),
      ).join();
      expect(storage.value, expected);
    });

    test('reuses a valid existing key without entropy or writes', () async {
      final storage = FakeStorage(value: 'ab' * 32);
      final entropy = FixedEntropy(List<int>.filled(32, 1));
      final service = SecureKeyService(storage: storage, entropy: entropy);

      final result = await service.loadOrCreate(databaseExists: true);

      expect(result, isA<Ok<DatabaseKey>>());
      expect(storage.writes, 0);
      expect(entropy.calls, 0);
    });

    test(
      'refuses missing, blank, malformed, or unavailable existing keys',
      () async {
        for (final storage in <FakeStorage>[
          FakeStorage(),
          FakeStorage(value: ''),
          FakeStorage(value: 'not-a-key'),
          FakeStorage(throwOnRead: true),
        ]) {
          final service = SecureKeyService(
            storage: storage,
            entropy: FixedEntropy(List<int>.filled(32, 0)),
          );

          final result = await service.loadOrCreate(databaseExists: true);

          expect(result, isA<Err<DatabaseKey>>());
          expect(
            (result as Err<DatabaseKey>).failure,
            isA<EncryptionFailure>(),
          );
          expect(storage.writes, 0);
        }
      },
    );

    test(
      'returns encryption failure when creation cannot be read back',
      () async {
        final storage = FakeStorage(readAfterWrite: 'cd' * 32);
        final service = SecureKeyService(
          storage: storage,
          entropy: FixedEntropy(List<int>.filled(32, 1)),
        );

        final result = await service.loadOrCreate(databaseExists: false);

        expect(result, isA<Err<DatabaseKey>>());
        expect((result as Err<DatabaseKey>).failure, isA<EncryptionFailure>());
      },
    );
  });
}

final class FixedEntropy implements EntropySource {
  FixedEntropy(this.value);

  final List<int> value;
  int calls = 0;

  @override
  List<int> bytes(int length) {
    calls++;
    return value;
  }
}

final class FakeStorage implements SecureKeyStorage {
  FakeStorage({this.value, this.readAfterWrite, this.throwOnRead = false});

  String? value;
  final String? readAfterWrite;
  final bool throwOnRead;
  int writes = 0;

  @override
  Future<String?> read() async {
    if (throwOnRead) throw StateError('storage unavailable');
    if (writes > 0 && readAfterWrite != null) return readAfterWrite;
    return value;
  }

  @override
  Future<void> write(String newValue) async {
    writes++;
    value = newValue;
  }
}
