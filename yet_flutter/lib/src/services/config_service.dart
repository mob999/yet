import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiEnvironment {
  final String name;
  final String baseUrl;
  final bool isSelected;

  ApiEnvironment({
    required this.name,
    required this.baseUrl,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'baseUrl': baseUrl,
    'isSelected': isSelected,
  };

  factory ApiEnvironment.fromJson(Map<String, dynamic> json) => ApiEnvironment(
    name: json['name'],
    baseUrl: json['baseUrl'],
    isSelected: json['isSelected'] ?? false,
  );

  ApiEnvironment copyWith({String? name, String? baseUrl, bool? isSelected}) {
    return ApiEnvironment(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ConfigService {
  static const String _envsKey = 'api_environments';
  static const String defaultBaseUrl = 'http://39.97.229.20:8000';

  final SharedPreferences _prefs;
  List<ApiEnvironment> _environments = [];

  ConfigService(this._prefs) {
    _loadEnvironments();
  }

  static Future<ConfigService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ConfigService(prefs);
  }

  void _loadEnvironments() {
    final jsonStr = _prefs.getString(_envsKey);
    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _environments = jsonList.map((e) => ApiEnvironment.fromJson(e)).toList();
    } else {
      // Initialize default
      _environments = [
        ApiEnvironment(
          name: 'Default Server',
          baseUrl: defaultBaseUrl,
          isSelected: true,
        ),
      ];
      _saveEnvironments();
    }
  }

  Future<void> _saveEnvironments() async {
    final jsonList = _environments.map((e) => e.toJson()).toList();
    await _prefs.setString(_envsKey, jsonEncode(jsonList));
  }

  List<ApiEnvironment> get environments => List.unmodifiable(_environments);

  String get baseUrl {
    try {
      return _environments.firstWhere((e) => e.isSelected).baseUrl;
    } catch (_) {
      return defaultBaseUrl;
    }
  }

  // Backward compatibility method, deprecated but kept for potential callers
  Future<void> setBaseUrl(String url) async {
    // This method now adds a custom env if not exists or updates selected
    await addEnvironment('Custom', url);
    // Select the last added (which is 'Custom' at the end or wherever it fits?)
    // Ideally we want specific environment management.
    // For compatibility, let's find one with this URL or create new
    final index = _environments.indexWhere((e) => e.baseUrl == url);
    if (index != -1) {
      await selectEnvironment(index);
    }
  }

  Future<void> addEnvironment(String name, String url) async {
    _environments.add(ApiEnvironment(name: name, baseUrl: url));
    await selectEnvironment(_environments.length - 1);
  }

  Future<void> updateEnvironment(int index, String name, String url) async {
    if (index >= 0 && index < _environments.length) {
      _environments[index] = _environments[index].copyWith(
        name: name,
        baseUrl: url,
      );
      // If it was selected, no change in selection needed
      await _saveEnvironments();
    }
  }

  Future<void> deleteEnvironment(int index) async {
    if (index >= 0 && index < _environments.length) {
      final wasSelected = _environments[index].isSelected;
      _environments.removeAt(index);
      if (wasSelected) {
        if (_environments.isNotEmpty) {
          _environments[0] = _environments[0].copyWith(isSelected: true);
        } else {
          // Restore default if empty
          _environments.add(
            ApiEnvironment(
              name: 'Default',
              baseUrl: defaultBaseUrl,
              isSelected: true,
            ),
          );
        }
      }
      await _saveEnvironments();
    }
  }

  Future<void> selectEnvironment(int index) async {
    if (index >= 0 && index < _environments.length) {
      _environments = _environments
          .map((e) => e.copyWith(isSelected: false))
          .toList();
      _environments[index] = _environments[index].copyWith(isSelected: true);
      await _saveEnvironments();
    }
  }
}
