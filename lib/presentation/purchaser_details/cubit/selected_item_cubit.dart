// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_item_state.dart';
part 'selected_item_cubit.freezed.dart';

class SelectedItemCubit extends Cubit<SelectedItemState> {
  SelectedItemCubit() : super(_InitialState(SelectedItemStateData()));

  void updateSelectedItem({required String? id}) {
    if (id != state.data.selectedItemId) {
      emit(UpdateSelectedItem(state.data.copyWith(selectedItemId: id)));
    }
  }
}
