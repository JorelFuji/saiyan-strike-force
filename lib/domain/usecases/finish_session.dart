import '../../core/result.dart';
import '../models/active_session.dart';
import '../repositories/session_repository.dart';

final class FinishSession {
  const FinishSession(this.repository);

  final SessionRepository repository;

  Future<Result<void>> call(FinishSessionCommand command) =>
      repository.finishSession(command);
}
