import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Тонкая обёртка над SharedPreferences: прогресс хранится одним JSON-документом.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;
  static const _progressKey = 'progress_v1';

  Map<String, dynamic>? loadProgress() {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProgress(Map<String, dynamic> data) =>
      _prefs.setString(_progressKey, jsonEncode(data));

  Future<void> clearProgress() => _prefs.remove(_progressKey);

  bool getBool(String key, bool defaultValue) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}
