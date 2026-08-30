// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/stored_purchaser_list.dart';
import '../../app/service/app_prefs_service.dart';

abstract class PurchaserDataSource {
  Future<void> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  });
  StoredPurchaserList getPurchaserList();

  /// Copies the stored list aside, unread and unparsed.
  ///
  /// Returns whether a copy was taken.
  Future<bool> backupPurchaserList();
}

class PurchaserDataSourceImpl implements PurchaserDataSource {
  PurchaserDataSourceImpl(this._pref);

  final AppPrefsServiceHelper _pref;

  static const purchaserListKey = 'PURCHASER_LIST_KEY';
  static const purchaserListBackupKey = 'PURCHASER_LIST_BACKUP_KEY';

  @override
  Future<void> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  }) async {
    await _pref.setValue<String>(
      purchaserListKey,
      json.encode(purchaserList.map((e) => e.toJson()).toList()),
    );
  }

  @override
  StoredPurchaserList getPurchaserList() {
    final jsonData = _pref.getValue<String>(purchaserListKey);

    if (jsonData == null) return const StoredPurchaserList();

    // Deliberately unguarded: a store that cannot be decoded at all must
    // reach the caller as a failure, not as an empty list, or the next write
    // replaces data the app was never able to see.
    final decoded = json.decode(jsonData) as List<dynamic>;

    final purchasers = <PurchaserModel>[];
    var skipped = 0;

    // Per record rather than in one pass: one unreadable record used to cost
    // the whole list, however well formed the rest of it was.
    for (final entry in decoded) {
      try {
        purchasers.add(PurchaserModel.fromJson(entry as Map<String, dynamic>));
      } catch (_) {
        skipped++;
      }
    }

    return StoredPurchaserList(purchasers: purchasers, skipped: skipped);
  }

  @override
  Future<bool> backupPurchaserList() async {
    final raw = _pref.getValue<String>(purchaserListKey);

    if (raw == null) return false;

    // Write once. The first copy is taken from the store as it stood before
    // the app wrote over it, so a later and more damaged state must not be
    // allowed to replace it.
    if (_pref.getValue<String>(purchaserListBackupKey) != null) return false;

    await _pref.setValue<String>(purchaserListBackupKey, raw);

    return true;
  }
}
