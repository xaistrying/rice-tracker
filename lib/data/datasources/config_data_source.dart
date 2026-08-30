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
}

class ConfigDataSourceImpl implements ConfigDataSource {
  ConfigDataSourceImpl(this._pref);

  final AppPrefsServiceHelper _pref;

  static const languageCodeKey = 'LANGUAGE_CODE_KEY';
  static const dateKey = 'DATE_KEY';

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
}
