import '../../core/result.dart';
import '../models/export_document.dart';

abstract interface class ExportShareService {
  Future<Result<ExportShareOutcome>> share(
    ExportDocument document, {
    required ExportShareOrigin origin,
  });
}
