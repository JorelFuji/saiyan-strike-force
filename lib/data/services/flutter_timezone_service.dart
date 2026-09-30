import 'package:flutter_timezone/flutter_timezone.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../domain/services/timezone_service.dart';

final class FlutterTimezoneService implements TimezoneService {
  @override
  Future<Result<String>> localIanaIdentifier() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      final identifier = timezone.identifier.trim();
      if (identifier.isEmpty) {
        return const Err(
          ValidationFailure('Device timezone identifier is empty.'),
        );
      }
      return Ok(identifier);
    } on Exception catch (error, stack) {
      return Err(
        StorageFailure(
          'Unable to read device timezone.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }
}
