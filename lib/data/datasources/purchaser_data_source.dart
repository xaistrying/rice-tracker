// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import '../../app/di/injector.dart';
import '../../app/service/app_prefs_service.dart';

abstract class PurchaserDataSource {
  Future<void> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  });
  List<PurchaserModel> getPurchaserList();
}

class PurchaserDataSourceImpl implements PurchaserDataSource {
  final _pref = getIt<AppPrefsServiceHelper>();

  static const purchaserListKey = 'PURCHASER_LIST_KEY';

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
  List<PurchaserModel> getPurchaserList() {
    String? jsonData = _pref.getValue<String>(purchaserListKey);
    List<PurchaserModel> purchaserList = [];

    if (jsonData != null && jsonData != '[]') {
      final List<dynamic> decoded = json.decode(jsonData);
      purchaserList = PurchaserModel.fromList(
        decoded.cast<Map<String, dynamic>>(),
      );
    }
    return purchaserList;
  }
}
