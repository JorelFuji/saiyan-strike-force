import '../../core/failure.dart';
import '../../core/result.dart';

/// An opaque, validated 256-bit key encoded for sqlite3mc's hex pragma.
final class DatabaseKey {
  const DatabaseKey._(this.hex);

  /// This value is only for encryption services; never log or surface it.
  final String hex;

  static Result<DatabaseKey> fromHex(String? value) {
    if (value == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
      return const Err(
        EncryptionFailure('Database encryption key is invalid.'),
      );
    }
    return Ok(DatabaseKey._(value));
  }

  bool sameAs(DatabaseKey other) => hex == other.hex;

  @override
  String toString() => 'DatabaseKey(redacted)';
}
