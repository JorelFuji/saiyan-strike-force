import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:vulcan/domain/repositories/settings_repository.dart';
import 'package:vulcan/features/settings/cubit/settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState.initial());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(const SettingsState.loading());
    final result = await _repository.getIsDarkMode().run();
    result.fold(
      (failure) => emit(SettingsState.error(failure: failure)),
      (isDarkMode) => emit(SettingsState.loaded(isDarkMode: isDarkMode)),
    );
  }

  Future<void> setDarkMode(bool value) async {
    final previous = state;
    emit(const SettingsState.loading());
    final result = await _repository.setIsDarkMode(value).run();
    result.fold(
      (failure) {
        emit(SettingsState.error(failure: failure));
        if (previous case SettingsLoaded(:final isDarkMode)) {
          emit(SettingsState.loaded(isDarkMode: isDarkMode));
        }
      },
      (_) => emit(SettingsState.loaded(isDarkMode: value)),
    );
  }
}
