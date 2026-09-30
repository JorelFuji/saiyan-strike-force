import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../models/export_document.dart';
import '../repositories/export_snapshot_repository.dart';
import '../services/export_share_service.dart';

final class ExportData {
  ExportData({
    required this.repository,
    required this.shareService,
    required this.clock,
    required this.appVersion,
  });
  final ExportSnapshotRepository repository;
  final ExportShareService shareService;
  final Clock clock;
  final String appVersion;

  Future<Result<ExportShareOutcome>> call({
    required ExportShareOrigin origin,
  }) async {
    if (appVersion.trim().isEmpty) {
      return const Err(ValidationFailure('App version is unavailable.'));
    }
    final snapshot = await repository.readSnapshot();
    return switch (snapshot) {
      Err(:final failure) => Err(failure),
      Ok(:final value) => shareService.share(
        ExportDocument(
          exportedAt: clock.now().toUtc(),
          appVersion: appVersion,
          collections: value,
        ),
        origin: origin,
      ),
    };
  }
}
