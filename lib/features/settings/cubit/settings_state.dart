import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan/core/error/failure.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;
  const factory SettingsState.loading() = SettingsLoading;
  const factory SettingsState.loaded({required bool isDarkMode}) =
      SettingsLoaded;
  const factory SettingsState.error({required Failure failure}) = SettingsError;
}
