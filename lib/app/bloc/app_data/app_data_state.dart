part of 'app_data_cubit.dart';

@freezed
abstract class AppDataStateData with _$AppDataStateData {
  const factory AppDataStateData({
    @Default([]) List<PurchaserModel> purchaserList,
  }) = _AppDataStateData;
}

@freezed
abstract class AppDataState with _$AppDataState {
  const factory AppDataState.initialState(AppDataStateData data) =
      _InitialState;
  const factory AppDataState.updateInProgress(AppDataStateData data) =
      UpdateInProgress;
  const factory AppDataState.updatePurchaserList(AppDataStateData data) =
      UpdatePurchaserList;
}
