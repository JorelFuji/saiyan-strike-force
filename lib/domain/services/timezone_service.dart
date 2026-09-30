import '../../core/result.dart';

abstract interface class TimezoneService {
  Future<Result<String>> localIanaIdentifier();
}
