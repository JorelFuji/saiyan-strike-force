import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vulcan/core/error/failure.dart';
import 'package:vulcan/domain/repositories/settings_repository.dart';
import 'package:vulcan/features/settings/cubit/settings_cubit.dart';
import 'package:vulcan/features/settings/cubit/settings_state.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;

  setUp(() {
    repository = _MockSettingsRepository();
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, loaded] when load succeeds',
      build: () {
        when(() => repository.getIsDarkMode()).thenReturn(
          TaskEither.right(true),
        );
        return SettingsCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const SettingsState.loading(),
        const SettingsState.loaded(isDarkMode: true),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, error] when load fails',
      build: () {
        when(() => repository.getIsDarkMode()).thenReturn(
          TaskEither.left(const Failure.cache(message: 'read failed')),
        );
        return SettingsCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const SettingsState.loading(),
        const SettingsState.error(
          failure: Failure.cache(message: 'read failed'),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, loaded] when setDarkMode succeeds',
      build: () {
        when(() => repository.setIsDarkMode(true)).thenReturn(
          TaskEither.right(unit),
        );
        return SettingsCubit(repository);
      },
      act: (cubit) => cubit.setDarkMode(true),
      expect: () => [
        const SettingsState.loading(),
        const SettingsState.loaded(isDarkMode: true),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, error, previous loaded] when setDarkMode fails',
      build: () {
        when(() => repository.setIsDarkMode(false)).thenReturn(
          TaskEither.left(const Failure.cache(message: 'write failed')),
        );
        return SettingsCubit(repository);
      },
      seed: () => const SettingsState.loaded(isDarkMode: true),
      act: (cubit) => cubit.setDarkMode(false),
      expect: () => [
        const SettingsState.loading(),
        const SettingsState.error(
          failure: Failure.cache(message: 'write failed'),
        ),
        const SettingsState.loaded(isDarkMode: true),
      ],
    );
  });
}
