// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';
import '../models/tare_policy.dart';

abstract class ConfigRepository {
  Either<Failure, String> getLanguageCode();
  Future<Either<Failure, void>> cacheLanguageCode({
    required String languageCode,
  });

  /// The day the app was last opened, as an ISO 8601 string, or '' if it has
  /// never been recorded.
  Either<Failure, String> getDate();
  Future<Either<Failure, void>> cacheDate({required String date});

  /// The sack deduction as it stands: the switch, and the rate a purchaser
  /// starts at.
  ///
  /// Falls back to [TarePolicy.off] rather than failing when nothing has been
  /// stored yet, so a first run and a read error look the same to the caller:
  /// no deduction, and every total left exactly as it was weighed.
  Either<Failure, TarePolicy> getTarePolicy();
  Future<Either<Failure, void>> cacheTarePolicy(TarePolicy policy);
}
