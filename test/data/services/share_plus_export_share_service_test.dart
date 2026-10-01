import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/data/services/share_plus_export_share_service.dart';
import 'package:vulcan_fitness/domain/models/export_document.dart';

final class _Directory implements ExportTempDirectoryProvider {
  _Directory(this.value);
  final Directory value;
  @override
  Future<Directory> getTemporaryDirectory() async => value;
}

final class _Sharer implements ExportPlatformSharer {
  File? received;
  @override
  Future<ExportShareOutcome> share(File file, ExportShareOrigin origin) async {
    received = file;
    expect(await file.exists(), isTrue);
    expect(
      file.path,
      startsWith('${file.parent.path}${Platform.pathSeparator}'),
    );
    return ExportShareOutcome.dismissed;
  }
}

final class _SequenceRandom implements Random {
  int _calls = 0;
  @override
  int nextInt(int max) => _calls++ < 16 ? 0 : 1;
  @override
  bool nextBool() => nextInt(2) == 1;
  @override
  double nextDouble() => nextInt(1000) / 1000;
}

final class _ThrowingSharer implements ExportPlatformSharer {
  File? received;
  @override
  Future<ExportShareOutcome> share(File file, ExportShareOrigin origin) async {
    received = file;
    throw StateError('platform share failed');
  }
}

ExportDocument _document() => ExportDocument(
  exportedAt: DateTime.utc(2026, 9, 26, 15, 30),
  appVersion: '1+1',
  collections: ExportCollections(
    settings: const [],
    workouts: const [],
    workoutExercises: const [],
    workoutSets: const [],
    scheduleEntries: const [],
    sessions: const [],
    sessionExercises: const [],
    sessionSets: const [],
  ),
);

void main() {
  test(
    'writes a uniquely named JSON temp file and cleans it after dismissal',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'vf-export-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final sharer = _Sharer();
      final service = SharePlusExportShareService(
        directoryProvider: _Directory(directory),
        sharer: sharer,
        random: Random(3),
      );
      final document = _document();
      final result = await service.share(
        document,
        origin: const ExportShareOrigin(x: 1, y: 2, width: 3, height: 4),
      );
      expect(result, isA<Ok<ExportShareOutcome>>());
      expect(
        (result as Ok<ExportShareOutcome>).value,
        ExportShareOutcome.dismissed,
      );
      expect(
        sharer.received!.uri.pathSegments.last,
        matches(
          RegExp(
            r'^vulcan-fitness-export-20260926T153000Z-[0-9a-f]{16}\.json$',
          ),
        ),
      );
      expect(await sharer.received!.exists(), isFalse);
    },
  );

  test('collision preserves the existing file and retries with a new name', () async {
    final directory = await Directory.systemTemp.createTemp(
      'vf-export-collision-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final collision = File(
      '${directory.path}/vulcan-fitness-export-20260926T153000Z-0000000000000000.json',
    );
    await collision.writeAsString('keep');
    final sharer = _Sharer();
    final service = SharePlusExportShareService(
      directoryProvider: _Directory(directory),
      sharer: sharer,
      random: _SequenceRandom(),
    );
    final result = await service.share(
      _document(),
      origin: const ExportShareOrigin(x: 0, y: 0, width: 1, height: 1),
    );

    expect(result, isA<Ok<ExportShareOutcome>>());
    expect(await collision.readAsString(), 'keep');
    expect(sharer.received!.path, isNot(collision.path));
    expect(await sharer.received!.exists(), isFalse);
  });

  test('cleanup is attempted if the platform sharer throws', () async {
    final directory = await Directory.systemTemp.createTemp('vf-export-error-');
    addTearDown(() => directory.delete(recursive: true));
    final sharer = _ThrowingSharer();
    final service = SharePlusExportShareService(
      directoryProvider: _Directory(directory),
      sharer: sharer,
      random: Random(4),
    );
    final result = await service.share(
      _document(),
      origin: const ExportShareOrigin(x: 0, y: 0, width: 1, height: 1),
    );

    expect(result, isA<Err>());
    expect(await sharer.received!.exists(), isFalse);
  });
}
