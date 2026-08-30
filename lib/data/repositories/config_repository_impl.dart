// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';
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
}
