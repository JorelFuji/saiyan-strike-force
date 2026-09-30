import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/services/timezone_service.dart';

final class FakeTimezoneService implements TimezoneService {
  FakeTimezoneService({this.identifier = 'UTC'});

  String identifier;
  Result<String>? result;
  int readCalls = 0;

  @override
  Future<Result<String>> localIanaIdentifier() async {
    readCalls++;
    return result ?? Ok(identifier);
  }
}
