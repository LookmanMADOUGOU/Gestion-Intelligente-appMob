import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _keyPrefix = 'cache_';
  static const String _keyLastSync = 'last_sync_timestamp';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> save(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _prefs.setString('$_keyPrefix$key', jsonString);
    await _prefs.setString('${_keyPrefix}${key}_time', DateTime.now().toIso8601String());
    await _prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  static dynamic get(String key) {
    final raw = _prefs.getString('$_keyPrefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static DateTime? getLastCacheTime(String key) {
    final raw = _prefs.getString('${_keyPrefix}${key}_time');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static DateTime? getGlobalLastSyncTime() {
    final raw = _prefs.getString(_keyLastSync);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
