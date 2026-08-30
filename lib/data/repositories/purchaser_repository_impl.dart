// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import 'package:rice_tracker/app/error/failure.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/stored_purchaser_list.dart';
import 'package:rice_tracker/domain/repositories/purchaser_repository.dart';
import '../datasources/purchaser_data_source.dart';

class PurchaserRepositoryImpl implements PurchaserRepository {
  PurchaserRepositoryImpl(this._dataSource);

  final PurchaserDataSource _dataSource;

  @override
  Future<Either<Failure, void>> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  }) async {
    try {
      await _dataSource.cachePurchaserList(purchaserList: purchaserList);
      return const Right(null);
    } catch (e, s) {
      return Left(reportFailure('cachePurchaserList', e, s));
    }
  }

  @override
  Either<Failure, StoredPurchaserList> getPurchaserList() {
    try {
      final res = _dataSource.getPurchaserList();
      return Right(res);
    } catch (e, s) {
      return Left(reportFailure('getPurchaserList', e, s));
    }
  }

  @override
  Future<Either<Failure, bool>> backupPurchaserList() async {
    try {
      final res = await _dataSource.backupPurchaserList();
      return Right(res);
    } catch (e, s) {
      return Left(reportFailure('backupPurchaserList', e, s));
    }
  }
}
