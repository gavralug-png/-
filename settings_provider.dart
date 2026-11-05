import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage, this._audio) {
    sound = _storage.getBool(_kSound, true);
    music = _storage.getBool(_kMusic, true);
    darkTheme = _storage.getBool(_kDark, true);
    _audio.soundEnabled = sound;
    _audio.musicEnabled = music;
  }

  static const _kSound = 'settings_sound';
  static const _kMusic = 'settings_music';
  static const _kDark = 'settings_dark';

  final StorageService _storage;
  final AudioService _audio;

  bool sound = true;
  bool music = true;
  bool darkTheme = true;

  /// Вызывается один раз при старте приложения.
  Future<void> initAudio() async {
    await _audio.configure();
    if (music) await _audio.startMusic();
  }

  Future<void> setSound(bool value) async {
    sound = value;
    _audio.soundEnabled = value;
    notifyListeners();
    await _storage.setBool(_kSound, value);
  }

  Future<void> setMusic(bool value) async {
    music = value;
    notifyListeners();
    await _storage.setBool(_kMusic, value);
    await _audio.setMusic(value);
  }

  Future<void> setDarkTheme(bool value) async {
    darkTheme = value;
    notifyListeners();
    await _storage.setBool(_kDark, value);
  }
}
