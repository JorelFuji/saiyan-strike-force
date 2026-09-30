import '../../core/result.dart';
import '../repositories/session_repository.dart';

final class ResumeSession {
  const ResumeSession(this.repository);

  final SessionRepository repository;

  Future<Result<int?>> call() => repository.findResumableSessionId();
}
