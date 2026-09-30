import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/models/export_document.dart';
import '../../domain/services/export_share_service.dart';

abstract interface class ExportTempDirectoryProvider {
  Future<Directory> getTemporaryDirectory();
}

abstract interface class ExportPlatformSharer {
  Future<ExportShareOutcome> share(File file, ExportShareOrigin origin);
}

final class PathProviderExportTempDirectoryProvider
    implements ExportTempDirectoryProvider {
  const PathProviderExportTempDirectoryProvider();
  @override
  Future<Directory> getTemporaryDirectory() =>
      path_provider.getTemporaryDirectory();
}

final class SharePlusExportPlatformSharer implements ExportPlatformSharer {
  const SharePlusExportPlatformSharer();
  @override
  Future<ExportShareOutcome> share(File file, ExportShareOrigin origin) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: Rect.fromLTWH(
          origin.x,
          origin.y,
          origin.width,
          origin.height,
        ),
      ),
    );
    return switch (result.status) {
      ShareResultStatus.success => ExportShareOutcome.shared,
      ShareResultStatus.dismissed => ExportShareOutcome.dismissed,
      ShareResultStatus.unavailable => ExportShareOutcome.unavailable,
    };
  }
}

final class SharePlusExportShareService implements ExportShareService {
  SharePlusExportShareService({
    required this.directoryProvider,
    required this.sharer,
    Random? random,
  }) : _random = random ?? Random.secure();

  final ExportTempDirectoryProvider directoryProvider;
  final ExportPlatformSharer sharer;
  final Random _random;

  @override
  Future<Result<ExportShareOutcome>> share(
    ExportDocument document, {
    required ExportShareOrigin origin,
  }) async {
    File? file;
    try {
      final directory = await directoryProvider.getTemporaryDirectory();
      final stamp = _timestamp(document.exportedAt);
      for (var attempt = 0; attempt < 8; attempt++) {
        final suffix = List.generate(
          16,
          (_) => _random.nextInt(16).toRadixString(16),
        ).join();
        final candidate = File(
          p.join(directory.path, 'vulcan-fitness-export-$stamp-$suffix.json'),
        );
        try {
          await candidate.create(exclusive: true);
          file = candidate;
          break;
        } on FileSystemException {
          if (!await candidate.exists()) rethrow;
        }
      }
      if (file == null) {
        throw const FileSystemException(
          'Unable to allocate a unique export file.',
        );
      }
      await file.writeAsString(
        jsonEncode(document.toJson()),
        encoding: utf8,
        flush: true,
      );
      return Ok(await sharer.share(file, origin));
    } catch (error, stackTrace) {
      return Err(
        StorageFailure(
          'Unable to share the export.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (file != null) {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {
          // Temporary-file cleanup is best effort; never mask the share result.
        }
      }
    }
  }

  String _timestamp(DateTime input) {
    final value = input.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}${two(value.month)}${two(value.day)}T'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}Z';
  }
}
