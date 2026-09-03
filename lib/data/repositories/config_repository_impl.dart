// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';
import '../../domain/models/tare_policy.dart';
import '../../domain/models/tare_rate.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/config_data_source.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  ConfigRepositoryImpl(this._dataSource);

  final ConfigDataSource _dataSource;

  @override
  Either<Failure, String> getLanguageCode() {
    try {
      final res = _dataSource.getLanguageCode();
      if (res == null) {
        // Not an error: nothing has been chosen yet, and the caller falls back
        // to the device locale.
        return Left(Failure(message: 'No language code stored'));
      }
      return Right(res);
    } catch (e, s) {
      return Left(reportFailure('getLanguageCode', e, s));
    }
  }

  @override
  Future<Either<Failure, void>> cacheLanguageCode({
    required String languageCode,
  }) async {
    try {
      await _dataSource.cacheLanguageCode(languageCode: languageCode);
      return const Right(null);
    } catch (e, s) {
      return Left(reportFailure('cacheLanguageCode', e, s));
    }
  }

  @override
  Either<Failure, String> getDate() {
    try {
      final res = _dataSource.getDate();
      return Right(res);
    } catch (e, s) {
      return Left(reportFailure('getDate', e, s));
    }
  }

  @override
  Future<Either<Failure, void>> cacheDate({required String date}) async {
    try {
      await _dataSource.cacheDate(date: date);
      return const Right(null);
    } catch (e, s) {
      return Left(reportFailure('cacheDate', e, s));
    }
  }

  @override
  Either<Failure, TarePolicy> getTarePolicy() {
    try {
      final stored = _dataSource.getTareDefaultRate();

      final rate = stored == null
          ? TareRate.standard
          : TareRate(bags: stored.bags, kgTenths: stored.kgTenths);

      return Right(
        TarePolicy(
          // Off unless it was turned on. Defaulting the other way would take
          // a kilo off every existing record the moment the app updated.
          enabled: _dataSource.getTareEnabled() ?? false,
          // A pair written by a build with different bounds — or edited in the
          // prefs file by hand — could divide by zero, so it is checked here
          // rather than on every total that uses it.
          defaultRate: rate.isValid ? rate : TareRate.standard,
        ),
      );
    } catch (e, s) {
      return Left(reportFailure('getTarePolicy', e, s));
    }
  }

  @override
  Future<Either<Failure, void>> cacheTarePolicy(TarePolicy policy) async {
    try {
      await _dataSource.cacheTareEnabled(enabled: policy.enabled);
      await _dataSource.cacheTareDefaultRate(
        bags: policy.defaultRate.bags,
        kgTenths: policy.defaultRate.kgTenths,
      );
      return const Right(null);
    } catch (e, s) {
      return Left(reportFailure('cacheTarePolicy', e, s));
    }
  }
}
