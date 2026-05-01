part of 'app_data_cubit.dart';

@freezed
abstract class AppDataStateData with _$AppDataStateData {
  const factory AppDataStateData() = _AppDataStateData;
}

@freezed
abstract class AppDataState with _$AppDataState {
  const factory AppDataState.initialState(AppDataStateData data) =
      _InitialState;
}
