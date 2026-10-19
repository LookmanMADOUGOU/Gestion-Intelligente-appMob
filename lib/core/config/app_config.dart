import 'package:shared_preferences/shared_preferences.dart';
import 'environment.dart';

class AppConfig {
  static const String _keyCustomBaseUrl = 'smart_tech_custom_base_url';
  static const String _keyOfflineMode = 'smart_tech_offline_mode';

  static late SharedPreferences _prefs;
  static String _baseUrl = EnvironmentConfig.defaultBaseUrl;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedUrl = _prefs.getString(_keyCustomBaseUrl);
    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      _baseUrl = savedUrl.trim();
    } else {
      _baseUrl = EnvironmentConfig.defaultBaseUrl;
    }
  }

  static String get baseUrl => _baseUrl;

  static Future<void> setBaseUrl(String newUrl) async {
    String cleanUrl = newUrl.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    if (!cleanUrl.endsWith('/api')) {
      cleanUrl = '$cleanUrl/api';
    }
    _baseUrl = cleanUrl;
    await _prefs.setString(_keyCustomBaseUrl, _baseUrl);
  }

  static Future<void> resetBaseUrl() async {
    _baseUrl = EnvironmentConfig.defaultBaseUrl;
    await _prefs.remove(_keyCustomBaseUrl);
  }

  static bool get isOfflineModeEnabled => _prefs.getBool(_keyOfflineMode) ?? false;

  static Future<void> setOfflineModeEnabled(bool enabled) async {
    await _prefs.setBool(_keyOfflineMode, enabled);
  }
}
