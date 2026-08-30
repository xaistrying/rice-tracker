// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';
import '../models/purchaser_model.dart';
import '../models/stored_purchaser_list.dart';

abstract class PurchaserRepository {
  /// The stored list, along with whether all of it could be read.
  ///
  /// A [Left] means the store could not be read at all, which is not the same
  /// as it being empty: writing over it would destroy whatever it holds.
  Either<Failure, StoredPurchaserList> getPurchaserList();
  Future<Either<Failure, void>> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  });

  /// Copies the stored list aside before anything overwrites it.
  ///
  /// Returns whether a copy was taken; it is not taken twice.
  Future<Either<Failure, bool>> backupPurchaserList();
}
