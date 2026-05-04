// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import '../../../domain/repositories/purchaser_repository.dart';
import '../../extension/date_time_extension.dart';

part 'app_data_state.dart';
part 'app_data_cubit.freezed.dart';

class AppDataCubit extends Cubit<AppDataState> {
  AppDataCubit() : super(const _InitialState(AppDataStateData())) {
    _init();
  }

  final _purchaserRepo = getIt<PurchaserRepository>();

  void _init() {
    updatePurchaserList();
  }

  void updatePurchaserList() {
    final purchaserList = _purchaserRepo.getPurchaserList().getOrElse(
      (_) => [],
    );
    emit(
      UpdatePurchaserList(state.data.copyWith(purchaserList: purchaserList)),
    );
  }

  void addNewPurchaser({required String name}) {
    final purchaserList = [...state.data.purchaserList];

    purchaserList.add(
      PurchaserModel(
        id: DateTime.now().uniqueId,
        name: name,
        dateAdded: DateTime.now().toTimeString(),
      ),
    );
    _purchaserRepo.cachePurchaserList(purchaserList: purchaserList);

    emit(
      UpdatePurchaserList(state.data.copyWith(purchaserList: purchaserList)),
    );
  }

  void removePurchaser({required String? id}) {
    if (id == null) return;

    final purchaserList = [...state.data.purchaserList];

    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index != -1) {
      purchaserList.removeAt(index);
      _purchaserRepo.cachePurchaserList(purchaserList: purchaserList);
    }

    emit(
      UpdatePurchaserList(state.data.copyWith(purchaserList: purchaserList)),
    );
  }

  void updatePurchaserName({required String? id, required String? newName}) {
    emit(UpdateInProgress(state.data));

    if (id == null || newName == null) return;

    final purchaserList = [...state.data.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index != -1) {
      purchaserList[index].name = newName;
      _purchaserRepo.cachePurchaserList(purchaserList: purchaserList);
    }

    emit(
      UpdatePurchaserList(state.data.copyWith(purchaserList: purchaserList)),
    );
  }
}
