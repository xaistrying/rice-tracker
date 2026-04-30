// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../di/injector.dart';

class AppPrefsServiceHelper {
  final _pref = getIt<SharedPreferences>();

  /// Set String Value
  Future _setStringValue(String key, String value) async {
    await _pref.setString(key, value);
  }

  /// Set StringList Value
  Future _setStringListValue(String key, List<String> value) async {
    await _pref.setStringList(key, value);
  }

  /// Set Int Value
  Future _setIntValue(String key, int value) async {
    await _pref.setInt(key, value);
  }

  /// Set Boolean Value
  Future _setBooleanValue(String key, bool value) async {
    await _pref.setBool(key, value);
  }

  /// Set Double Value
  Future _setDoubleValue(String key, double value) async {
    await _pref.setDouble(key, value);
  }

  /// Get String Value
  String? _getStringValue(String key) {
    return _pref.getString(key);
  }

  /// Get StringList Value
  List? _getStringList(String key) {
    return _pref.getStringList(key);
  }

  /// Get Int Value
  int? _getIntValue(String key) {
    return _pref.getInt(key);
  }

  /// Get Boolean Value
  bool? _getBooleanValue(String key) {
    return _pref.getBool(key);
  }

  /// Get Double Value
  double? _getDoubleValue(String key) {
    return _pref.getDouble(key);
  }

  /// Set Value (Generic)
  Future<void> setValue<T>(String key, T value) async {
    if (value is String) {
      await _setStringValue(key, value);
    } else if (value is List<String>) {
      await _setStringListValue(key, value);
    } else if (value is int) {
      await _setIntValue(key, value);
    } else if (value is bool) {
      await _setBooleanValue(key, value);
    } else if (value is double) {
      await _setDoubleValue(key, value);
    } else {
      throw Exception('Unsupported type');
    }
  }

  // Get Value (Generic)
  T? getValue<T>(String key) {
    if (T == String) {
      return _getStringValue(key) as T?;
    } else if (T == List<String>) {
      return _getStringList(key) as T?;
    } else if (T == int) {
      return _getIntValue(key) as T?;
    } else if (T == bool) {
      return _getBooleanValue(key) as T?;
    } else if (T == double) {
      return _getDoubleValue(key) as T?;
    } else {
      throw Exception('Unsupported type');
    }
  }

  /// Remove Value
  Future<void> removeValue(String key) async {
    await _pref.remove(key);
  }
}
