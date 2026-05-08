// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import 'package:rice_tracker/app/error/failure.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/repositories/purchaser_repository.dart';
import '../../app/di/injector.dart';
import '../datasources/purchaser_data_source.dart';

class PurchaserRepositoryImpl implements PurchaserRepository {
  final _dataSource = getIt<PurchaserDataSource>();

  @override
  Future<Either<Failure, void>> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  }) async {
    try {
      _dataSource.cachePurchaserList(purchaserList: purchaserList);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Either<Failure, List<PurchaserModel>> getPurchaserList() {
    try {
      final res = _dataSource.getPurchaserList();
      return Right(res);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheDate({required String date}) async {
    try {
      _dataSource.cacheDate(date: date);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Either<Failure, String> getDate() {
    try {
      final res = _dataSource.getDate();
      return Right(res);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
