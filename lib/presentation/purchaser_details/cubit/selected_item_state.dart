part of 'selected_item_cubit.dart';

@freezed
abstract class SelectedItemStateData with _$SelectedItemStateData {
  const factory SelectedItemStateData({String? selectedItemId}) =
      _SelectedItemStateData;
}

@freezed
abstract class SelectedItemState with _$SelectedItemState {
  const factory SelectedItemState.initialState(SelectedItemStateData data) =
      _InitialState;
  const factory SelectedItemState.updateSelectedItem(
    SelectedItemStateData data,
  ) = UpdateSelectedItem;
}
