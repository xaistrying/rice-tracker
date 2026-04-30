// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';

abstract class ConfigRepository {
  Either<Failure, String> getLanguageCode();
  Future<Either<Failure, void>> cacheLanguageCode({
    required String languageCode,
  });
}
