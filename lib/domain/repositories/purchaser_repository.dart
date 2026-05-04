// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import '../../app/error/failure.dart';
import '../models/purchaser_model.dart';

abstract class PurchaserRepository {
  Either<Failure, List<PurchaserModel>> getPurchaserList();
  Future<Either<Failure, void>> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  });
}
