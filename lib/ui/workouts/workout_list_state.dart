import '../../domain/models/workout_template.dart';

enum WorkoutListLoadPhase { loading, ready, failure }

enum WorkoutListFilter { active, archived }

enum WorkoutTemplateAction { archive, restore }

final class WorkoutListState {
  WorkoutListState({
    this.loadPhase = WorkoutListLoadPhase.loading,
    List<WorkoutTemplate> templates = const [],
    this.filter = WorkoutListFilter.active,
    this.query = '',
    this.pendingTemplateId,
    this.pendingAction,
    this.failureMessage,
    this.retryTemplateId,
    this.retryAction,
    this.postCommitArchiveId,
  }) : templates = List.unmodifiable(templates);

  final WorkoutListLoadPhase loadPhase;
  final List<WorkoutTemplate> templates;
  final WorkoutListFilter filter;
  final String query;
  final int? pendingTemplateId;
  final WorkoutTemplateAction? pendingAction;
  final String? failureMessage;
  final int? retryTemplateId;
  final WorkoutTemplateAction? retryAction;
  final int? postCommitArchiveId;

  List<WorkoutTemplate> get visibleTemplates {
    final normalized = query.trim().toLowerCase();
    return templates
        .where((template) {
          final matchesFilter = filter == WorkoutListFilter.active
              ? template.archivedAt == null
              : template.archivedAt != null;
          return matchesFilter &&
              (normalized.isEmpty ||
                  template.name.toLowerCase().contains(normalized));
        })
        .toList(growable: false);
  }

  WorkoutListState copyWith({
    WorkoutListLoadPhase? loadPhase,
    List<WorkoutTemplate>? templates,
    WorkoutListFilter? filter,
    String? query,
    int? pendingTemplateId,
    bool clearPending = false,
    WorkoutTemplateAction? pendingAction,
    String? failureMessage,
    bool clearFailure = false,
    int? retryTemplateId,
    WorkoutTemplateAction? retryAction,
    bool clearRetry = false,
    int? postCommitArchiveId,
    bool clearPostCommitArchive = false,
  }) => WorkoutListState(
    loadPhase: loadPhase ?? this.loadPhase,
    templates: templates ?? this.templates,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    pendingTemplateId: clearPending
        ? null
        : (pendingTemplateId ?? this.pendingTemplateId),
    pendingAction: clearPending ? null : (pendingAction ?? this.pendingAction),
    failureMessage: clearFailure
        ? null
        : (failureMessage ?? this.failureMessage),
    retryTemplateId: clearRetry
        ? null
        : (retryTemplateId ?? this.retryTemplateId),
    retryAction: clearRetry ? null : (retryAction ?? this.retryAction),
    postCommitArchiveId: clearPostCommitArchive
        ? null
        : (postCommitArchiveId ?? this.postCommitArchiveId),
  );
}
