// Project imports:
import 'purchaser_model.dart';

/// What came back from storage, and whether all of it came back.
///
/// Writing replaces the whole list, so a read that quietly dropped records
/// would let the next ordinary edit destroy them. [skipped] carries that fact
/// up to the caller instead of leaving a partial read looking like a complete
/// one.
class StoredPurchaserList {
  const StoredPurchaserList({this.purchasers = const [], this.skipped = 0});

  final List<PurchaserModel> purchasers;

  /// Records that are present in storage but could not be parsed.
  final int skipped;

  /// Whether every stored record was read.
  bool get isComplete => skipped == 0;
}
