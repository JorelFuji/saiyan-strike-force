import '../../core/result.dart';
import '../models/export_document.dart';

abstract interface class ExportSnapshotRepository {
  Future<Result<ExportCollections>> readSnapshot();
}
