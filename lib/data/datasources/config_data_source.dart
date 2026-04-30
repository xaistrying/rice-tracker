// Project imports:
import '../../app/di/injector.dart';
import '../../app/service/app_prefs_service.dart';

abstract class ConfigDataSource {
  Future<void> cacheLanguageCode({required String languageCode});
  String? getLanguageCode();
  Future<void> cacheDarkModeStatus({required bool status});
  bool? getDarkModeStatus();
}

class ConfigDataSourceImpl implements ConfigDataSource {
  final _pref = getIt<AppPrefsServiceHelper>();

  static const languageCodeKey = 'LANGUAGE_CODE_KEY';
  static const darmModeStatusKey = 'DARK_MODE_STATUS_KEY';

  @override
  Future<void> cacheLanguageCode({required String languageCode}) async {
    await _pref.setValue<String>(languageCodeKey, languageCode);
  }

  @override
  String? getLanguageCode() {
    return _pref.getValue<String>(languageCodeKey);
  }

  @override
  Future<void> cacheDarkModeStatus({required bool status}) async {
    await _pref.setValue<bool>(darmModeStatusKey, status);
  }

  @override
  bool? getDarkModeStatus() {
    return _pref.getValue<bool>(darmModeStatusKey);
  }
}
