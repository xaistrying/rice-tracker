part of 'app_config_cubit.dart';

@freezed
abstract class AppConfigStateData with _$AppConfigStateData {
  const factory AppConfigStateData({
    final Locale? locale,
    @Default(ThemeMode.system) ThemeMode? themeMode,

    /// Read from the installed package, not from a constant in the source.
    ///
    /// Null until it has been read, and if it cannot be read at all — the
    /// Settings screen leaves the line out rather than showing a blank or a
    /// guess, since a wrong version number is worse than none when someone is
    /// reporting a problem.
    String? version,
    String? buildNumber,

    /// Off until the stored setting is read, which is one frame after launch.
    /// Starting from off means the first frame shows what was weighed rather
    /// than briefly deducting at a rate that has not been loaded yet.
    @Default(TarePolicy.off) TarePolicy tarePolicy,
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
  const factory AppConfigState.updateTarePolicy(AppConfigStateData data) =
      UpdateTarePolicy;
  const factory AppConfigState.updateVersion(AppConfigStateData data) =
      UpdateVersion;
}
