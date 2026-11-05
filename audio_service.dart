import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'sound_synth.dart';

/// Звуковые эффекты и фоновая музыка. Все вызовы безопасны: ошибки аудио
/// никогда не должны ломать игру.
class AudioService {
  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  late final Uint8List _musicBytes = SoundSynth.ambientLoop();
  late final Uint8List _correctBytes = SoundSynth.correct();
  late final Uint8List _wrongBytes = SoundSynth.wrong();

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool _musicStarted = false;

  Future<void> configure() async {
    try {
      final ctx =
          AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
              .build();
      await _music.setAudioContext(ctx);
      await _sfx.setAudioContext(ctx);
    } catch (e) {
      debugPrint('Audio configure error: $e');
    }
  }

  Future<void> setMusic(bool on) async {
    musicEnabled = on;
    if (on) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> startMusic() async {
    if (!musicEnabled || _musicStarted) return;
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.22);
      await _music.play(BytesSource(_musicBytes));
      _musicStarted = true;
    } catch (e) {
      debugPrint('Music start error: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _music.stop();
    } catch (_) {}
    _musicStarted = false;
  }

  Future<void> pauseMusic() async {
    if (!_musicStarted) return;
    try {
      await _music.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!_musicStarted || !musicEnabled) return;
    try {
      await _music.resume();
    } catch (_) {}
  }

  Future<void> playResult(bool correct) async {
    if (!soundEnabled) return;
    try {
      await _sfx.stop();
      await _sfx.setVolume(0.7);
      await _sfx.play(BytesSource(correct ? _correctBytes : _wrongBytes));
    } catch (e) {
      debugPrint('SFX error: $e');
    }
  }

  void dispose() {
    _music.dispose();
    _sfx.dispose();
  }
}
