import '../../../core/failure.dart';
import '../../../core/result.dart';

String formatRestDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '$minutes:${remainder.toString().padLeft(2, '0')}';
}

Result<int> parseRestDuration(String input) {
  final value = input.trim();
  if (value.startsWith('-')) {
    return const Err(ValidationFailure('Rest duration must not be negative.'));
  }
  final parts = value.split(':');
  if (parts.length == 2) {
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null || minutes < 0 || seconds < 0) {
      return const Err(ValidationFailure('Enter rest as m:ss or seconds.'));
    }
    if (seconds >= 60) {
      return const Err(ValidationFailure('Rest seconds must be below 60.'));
    }
    return Ok(minutes * 60 + seconds);
  }
  final seconds = int.tryParse(value);
  return seconds == null || seconds < 0
      ? const Err(ValidationFailure('Enter rest as m:ss or seconds.'))
      : Ok(seconds);
}
