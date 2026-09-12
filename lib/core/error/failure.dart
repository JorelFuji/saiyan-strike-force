import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.cache({String? message}) = CacheFailure;
  const factory Failure.storage({String? message}) = StorageFailure;
  const factory Failure.unexpected({String? message}) = UnexpectedFailure;
}
