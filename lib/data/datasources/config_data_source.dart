// Project imports:
import '../../app/service/app_prefs_service.dart';

abstract class ConfigDataSource {
  Future<void> cacheLanguageCode({required String languageCode});
  String? getLanguageCode();

  /// The day the app was last opened, as an ISO 8601 string.
  ///
  /// App state rather than purchaser data, which is why it lives here: it only
  /// exists so the list's date headers can be refreshed when the day rolls
  /// over while the app is in the background.
  Future<void> cacheDate({required String date});
  String getDate();

  /// Whether the weight of the empty sacks is taken off every total.
  ///
  /// Null when it has never been set, which the repository reads as off: an
  /// upgrade must not silently restate every total already on file.
  Future<void> cacheTareEnabled({required bool enabled});
  bool? getTareEnabled();

  /// The rate a purchaser starts at, as the pair it is quoted in.
  ///
  /// Null unless both halves were written.
  Future<void> cacheTareDefaultRate({required int bags, required int kgTenths});
  ({int bags, int kgTenths})? getTareDefaultRate();
}

class ConfigDataSourceImpl implements ConfigDataSource {
  ConfigDataSourceImpl(this._pref);

  final AppPrefsServiceHelper _pref;

  static const languageCodeKey = 'LANGUAGE_CODE_KEY';
  static const dateKey = 'DATE_KEY';
  static const tareEnabledKey = 'TARE_ENABLED_KEY';
  static const tareDefaultBagsKey = 'TARE_DEFAULT_BAGS_KEY';
  static const tareDefaultKgTenthsKey = 'TARE_DEFAULT_KG_TENTHS_KEY';

  @override
  Future<void> cacheLanguageCode({required String languageCode}) async {
    await _pref.setValue<String>(languageCodeKey, languageCode);
  }

  @override
  String? getLanguageCode() {
    return _pref.getValue<String>(languageCodeKey);
  }

  @override
  Future<void> cacheDate({required String date}) async {
    await _pref.setValue<String>(dateKey, date);
  }

  @override
  String getDate() {
    return _pref.getValue<String>(dateKey) ?? '';
  }

  @override
  Future<void> cacheTareEnabled({required bool enabled}) async {
    await _pref.setValue<bool>(tareEnabledKey, enabled);
  }

  @override
  bool? getTareEnabled() {
    return _pref.getValue<bool>(tareEnabledKey);
  }

  @override
  Future<void> cacheTareDefaultRate({
    required int bags,
    required int kgTenths,
  }) async {
    await _pref.setValue<int>(tareDefaultBagsKey, bags);
    await _pref.setValue<int>(tareDefaultKgTenthsKey, kgTenths);
  }

  @override
  ({int bags, int kgTenths})? getTareDefaultRate() {
    final bags = _pref.getValue<int>(tareDefaultBagsKey);
    final kgTenths = _pref.getValue<int>(tareDefaultKgTenthsKey);

    // Both or neither. The two are written in sequence, so a write refused
    // between them leaves one half of a rate behind, and half a rate is not a
    // rate — the caller falls back to the standard one.
    if (bags == null || kgTenths == null) return null;

    return (bags: bags, kgTenths: kgTenths);
  }
}
