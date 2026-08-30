// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../di/injector.dart';

class AppPrefsServiceHelper {
  final _pref = getIt<SharedPreferences>();

  /// Set String Value
  Future<bool> _setStringValue(String key, String value) {
    return _pref.setString(key, value);
  }

  /// Set StringList Value
  Future<bool> _setStringListValue(String key, List<String> value) {
    return _pref.setStringList(key, value);
  }

  /// Set Int Value
  Future<bool> _setIntValue(String key, int value) {
    return _pref.setInt(key, value);
  }

  /// Set Boolean Value
  Future<bool> _setBooleanValue(String key, bool value) {
    return _pref.setBool(key, value);
  }

  /// Set Double Value
  Future<bool> _setDoubleValue(String key, double value) {
    return _pref.setDouble(key, value);
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
  ///
  /// Throws if the value could not be persisted. The platform reports a
  /// refused write (a full or unwritable store) by returning false rather
  /// than throwing, so that result has to be turned into an error here or it
  /// is invisible to callers.
  Future<void> setValue<T>(String key, T value) async {
    final bool written;

    if (value is String) {
      written = await _setStringValue(key, value);
    } else if (value is List<String>) {
      written = await _setStringListValue(key, value);
    } else if (value is int) {
      written = await _setIntValue(key, value);
    } else if (value is bool) {
      written = await _setBooleanValue(key, value);
    } else if (value is double) {
      written = await _setDoubleValue(key, value);
    } else {
      throw Exception('Unsupported type');
    }

    if (!written) {
      throw Exception('Failed to persist value for "$key"');
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
