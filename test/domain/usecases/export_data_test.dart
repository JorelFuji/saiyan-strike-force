import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/clock.dart';
import 'package:vulcan_fitness/core/failure.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/export_document.dart';
import 'package:vulcan_fitness/domain/repositories/export_snapshot_repository.dart';
import 'package:vulcan_fitness/domain/services/export_share_service.dart';
import 'package:vulcan_fitness/domain/usecases/export_data.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 26);
}

final class _Repository implements ExportSnapshotRepository {
  _Repository(this.result);
  final Result<ExportCollections> result;
  @override
  Future<Result<ExportCollections>> readSnapshot() async => result;
}

final class _Share implements ExportShareService {
  int calls = 0;
  ExportDocument? document;
  @override
  Future<Result<ExportShareOutcome>> share(
    ExportDocument value, {
    required ExportShareOrigin origin,
  }) async {
    calls++;
    document = value;
    return const Ok(ExportShareOutcome.dismissed);
  }
}

void main() {
  test('uses injected version and UTC clock after complete snapshot', () async {
    final snapshot = ExportCollections(
      settings: const [],
      workouts: const [],
      workoutExercises: const [],
      scheduleEntries: const [],
      sessions: const [],
      sessionExercises: const [],
      sessionSets: const [],
    );
    final share = _Share();
    final result = await ExportData(
      repository: _Repository(Ok(snapshot)),
      shareService: share,
      clock: _Clock(),
      appVersion: 'test+4',
    )(origin: const ExportShareOrigin(x: 1, y: 2, width: 3, height: 4));
    expect(result, isA<Ok<ExportShareOutcome>>());
    expect(share.calls, 1);
    expect(share.document!.appVersion, 'test+4');
    expect(share.document!.exportedAt, DateTime.utc(2026, 9, 26));
  });

  test('does not share a partial snapshot after read failure', () async {
    final share = _Share();
    final result = await ExportData(
      repository: _Repository(const Err(StorageFailure('read failed'))),
      shareService: share,
      clock: _Clock(),
      appVersion: 'test',
    )(origin: const ExportShareOrigin(x: 0, y: 0, width: 1, height: 1));
    expect(result, isA<Err<ExportShareOutcome>>());
    expect(share.calls, 0);
  });
}
