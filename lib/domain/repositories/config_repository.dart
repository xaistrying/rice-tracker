// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';

abstract class ConfigRepository {
  Either<Failure, String> getLanguageCode();
  Future<Either<Failure, void>> cacheLanguageCode({
    required String languageCode,
  });

  /// The day the app was last opened, as an ISO 8601 string, or '' if it has
  /// never been recorded.
  Either<Failure, String> getDate();
  Future<Either<Failure, void>> cacheDate({required String date});
}
