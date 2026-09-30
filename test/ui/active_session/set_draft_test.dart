import 'package:flutter_test/flutter_test.dart';
import 'package:vulcan_fitness/core/result.dart';
import 'package:vulcan_fitness/domain/models/active_session.dart';
import 'package:vulcan_fitness/domain/models/mass.dart';
import 'package:vulcan_fitness/domain/models/prescriptions.dart';
import 'package:vulcan_fitness/ui/active_session/set_draft.dart';

void main() {
  SessionSetSnapshot set({
    RepPrescription? plannedReps,
    LoadPrescription? plannedLoad,
    ActualPrescription? actual,
  }) {
    return (SessionSetSnapshot.create(
      id: 1,
      sessionExerciseId: 1,
      setIndex: 0,
      plannedReps:
          plannedReps ??
          (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
      plannedLoad: plannedLoad ?? LoadPrescription.bodyweight,
      actual: actual,
      completed: false,
    ) as Ok<SessionSetSnapshot>).value;
  }

  test('seeds fixed planned reps and actual values when present', () {
    final actual = (ActualPrescription.create(
      reps: (RepPrescription.fixed(8) as Ok<RepPrescription>).value,
      load: (LoadPrescription.absolute(2500000) as Ok<LoadPrescription>).value,
    ) as Ok<ActualPrescription>).value;

    final draft = SetDraft.seed(
      set(
        plannedReps: (RepPrescription.fixed(5) as Ok<RepPrescription>).value,
        actual: actual,
      ),
      MassUnit.kg,
    );

    expect(draft.repsText, '8');
    expect(draft.absoluteMassText, '2.5');
    expect(draft.dirty, isFalse);
  });

  test('does not guess reps for range or AMRAP plans', () {
    final rangeDraft = SetDraft.seed(
      set(
        plannedReps:
            (RepPrescription.range(8, 12) as Ok<RepPrescription>).value,
      ),
      MassUnit.kg,
    );
    expect(rangeDraft.repsText, isEmpty);

    final amrapDraft = SetDraft.seed(
      set(plannedReps: RepPrescription.amrap),
      MassUnit.kg,
    );
    expect(amrapDraft.repsText, isEmpty);
  });

  test('parses performed reps and absolute load using display unit', () {
    final draft = SetDraft(
      repsText: '10',
      loadKind: LoadType.absolute,
      absoluteMassText: '225',
    );

    final lbActual = draft.toActual(MassUnit.lb);
    expect(lbActual, isA<Ok<ActualPrescription>>());
    final load = (lbActual as Ok<ActualPrescription>).value.load;
    expect(load, isA<AbsoluteLoad>());
    expect(
      (load as AbsoluteLoad).milligrams,
      (massToMilligrams('225', MassUnit.lb) as Ok<int>).value,
    );

    final invalidReps = draft.copyWith(repsText: '0').toActual(MassUnit.lb);
    expect(invalidReps, isA<Err<ActualPrescription>>());
  });

  test('validates every supported load type', () {
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.none,
      ).toActual(MassUnit.kg),
      isA<Ok<ActualPrescription>>(),
    );
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.bodyweight,
      ).toActual(MassUnit.kg),
      isA<Ok<ActualPrescription>>(),
    );
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.percentage,
        percentageText: '85',
      ).toActual(MassUnit.kg),
      isA<Ok<ActualPrescription>>(),
    );
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.targetRpe,
        targetRpeText: '8',
      ).toActual(MassUnit.kg),
      isA<Ok<ActualPrescription>>(),
    );
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.text,
        textLoadText: 'Heavy band',
      ).toActual(MassUnit.kg),
      isA<Ok<ActualPrescription>>(),
    );
    expect(
      const SetDraft(
        repsText: '5',
        loadKind: LoadType.percentage,
        percentageText: 'abc',
      ).toActual(MassUnit.kg),
      isA<Err<ActualPrescription>>(),
    );
  });
}
