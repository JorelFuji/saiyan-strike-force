import 'package:drift/drift.dart';

import '../../domain/models/session_status.dart';
import '../database/app_database.dart';

/// Shared active-session mutation guards. The facade owns transaction/retry/error mapping.
final class SessionMutationWriter {
  SessionMutationWriter(this.database);
  final AppDatabase database;

  Future<bool> hasActiveSession() async =>
      (await (database.select(database.session)..where(
                (row) =>
                    row.status.equals(SessionStatus.running.wireValue) |
                    row.status.equals(SessionStatus.paused.wireValue),
              ))
              .get())
          .isNotEmpty;
}
