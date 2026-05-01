// Project imports:
import '../../app/di/injector.dart';
import '../../app/service/app_prefs_service.dart';

abstract class ConfigDataSource {
  Future<void> cacheLanguageCode({required String languageCode});
  String? getLanguageCode();
}

class ConfigDataSourceImpl implements ConfigDataSource {
  final _pref = getIt<AppPrefsServiceHelper>();

  static const languageCodeKey = 'LANGUAGE_CODE_KEY';

  @override
  Future<void> cacheLanguageCode({required String languageCode}) async {
    await _pref.setValue<String>(languageCodeKey, languageCode);
  }

  @override
  String? getLanguageCode() {
    return _pref.getValue<String>(languageCodeKey);
  }
}
