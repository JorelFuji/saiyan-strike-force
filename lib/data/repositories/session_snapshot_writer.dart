import '../database/app_database.dart';

/// Snapshot graph write boundary. It deliberately receives the facade-owned
/// transaction callback, so it cannot create a second transaction.
final class SessionSnapshotWriter {
  SessionSnapshotWriter(this.database);
  final AppDatabase database;

  Future<T> withinFacadeTransaction<T>(Future<T> Function() write) => write();
}
