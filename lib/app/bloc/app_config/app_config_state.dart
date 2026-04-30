part of 'app_config_cubit.dart';

@freezed
abstract class AppConfigStateData with _$AppConfigStateData {
  const factory AppConfigStateData({
    final Locale? locale,
    @Default(ThemeMode.system) ThemeMode? themeMode,
    String? version,
  }) = _AppConfigStateData;
}

@freezed
abstract class AppConfigState with _$AppConfigState {
  const factory AppConfigState.initialState(AppConfigStateData data) =
      _InitialState;
  const factory AppConfigState.updateLocaleState(AppConfigStateData data) =
      UpdateLocaleState;
  const factory AppConfigState.updateThemeMode(AppConfigStateData data) =
      UpdateThemeMode;
}