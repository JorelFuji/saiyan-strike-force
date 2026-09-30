import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import 'database_key.dart';

abstract interface class EntropySource {
  List<int> bytes(int length);
}

final class SecureEntropySource implements EntropySource {
  SecureEntropySource() : _random = Random.secure();

  final Random _random;

  @override
  List<int> bytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256), growable: false);
}

abstract interface class SecureKeyStorage {
  Future<String?> read();
  Future<void> write(String value);
}

final class FlutterSecureKeyStorage implements SecureKeyStorage {
  FlutterSecureKeyStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
            aOptions: AndroidOptions(
              resetOnError: false,
              migrateWithBackup: false,
              storageNamespace: 'vulcan_fitness_database_key',
            ),
          );

  static const _storageKey = 'database_encryption_key';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _storageKey);

  @override
  Future<void> write(String value) =>
      _storage.write(key: _storageKey, value: value);
}

/// Preserves the original key forever once a database file exists.
class SecureKeyService {
  SecureKeyService({required this.storage, required this.entropy});

  factory SecureKeyService.production() => SecureKeyService(
    storage: FlutterSecureKeyStorage(),
    entropy: SecureEntropySource(),
  );

  final SecureKeyStorage storage;
  final EntropySource entropy;

  Future<Result<DatabaseKey>> loadOrCreate({
    required bool databaseExists,
  }) async {
    try {
      final stored = await storage.read();
      final parsed = DatabaseKey.fromHex(stored);
      if (parsed case Ok<DatabaseKey>()) {
        return parsed;
      }
      if (stored != null || databaseExists) {
        return const Err(
          EncryptionFailure('Database encryption key is unavailable.'),
        );
      }

      final created = DatabaseKey.fromHex(_encodeHex(entropy.bytes(32)));
      if (created case Err<DatabaseKey>()) {
        return const Err(
          EncryptionFailure('Database encryption key could not be created.'),
        );
      }
      final key = (created as Ok<DatabaseKey>).value;
      await storage.write(key.hex);
      final confirmed = DatabaseKey.fromHex(await storage.read());
      if (confirmed case Ok<DatabaseKey>(:final value) when value.sameAs(key)) {
        return confirmed;
      }
      return const Err(
        EncryptionFailure('Database encryption key could not be verified.'),
      );
    } catch (_) {
      return const Err(
        EncryptionFailure('Database encryption key is unavailable.'),
      );
    }
  }

  static String _encodeHex(List<int> bytes) {
    if (bytes.length != 32 || bytes.any((byte) => byte < 0 || byte > 255)) {
      throw ArgumentError.value(bytes, 'bytes', 'Expected 32 bytes.');
    }
    const digits = '0123456789abcdef';
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer
        ..write(digits[byte >> 4])
        ..write(digits[byte & 0x0f]);
    }
    return buffer.toString();
  }
}
