import 'package:fpdart/fpdart.dart';
import 'package:vulcan/core/error/failure.dart';

abstract class SettingsRepository {
  TaskEither<Failure, bool> getIsDarkMode();

  TaskEither<Failure, Unit> setIsDarkMode(bool value);
}
