// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/di/injector.dart';
import '../../app/error/failure.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/config_data_source.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final _dataSource = getIt<ConfigDataSource>();

  @override
  Either<Failure, String> getLanguageCode() {
    try {
      final res = _dataSource.getLanguageCode();
      if (res == null) {
        return Left(Failure(message: 'Value is none'));
      }
      return Right(res);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheLanguageCode({
    required String languageCode,
  }) async {
    try {
      await _dataSource.cacheLanguageCode(languageCode: languageCode);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
