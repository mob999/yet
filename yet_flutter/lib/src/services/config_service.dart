import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _baseUrlKey = 'api_base_url';
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';

  final SharedPreferences _prefs;

  ConfigService(this._prefs);

  static Future<ConfigService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ConfigService(prefs);
  }

  String get baseUrl => _prefs.getString(_baseUrlKey) ?? defaultBaseUrl;

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_baseUrlKey, url);
  }
}
