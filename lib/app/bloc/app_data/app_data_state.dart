part of 'app_data_cubit.dart';

/// What went wrong the last time the store was read.
///
/// [partial] is the more dangerous of the two: the list looks perfectly normal
/// with a record missing from it, so without saying so there is nothing at all
/// to notice. [unreadable] at least shows an empty list — but that is exactly
/// what a fresh install shows, so it is just as indistinguishable.
enum StoreReadIssue { unreadable, partial }

@freezed
abstract class AppDataStateData with _$AppDataStateData {
  const factory AppDataStateData({
    @Default([]) List<PurchaserModel> purchaserList,

    /// Null when the last read returned everything that was stored.
    StoreReadIssue? readIssue,

    /// How many records could not be parsed. Only meaningful alongside
    /// [StoreReadIssue.partial].
    @Default(0) int unreadableRecords,
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
