import 'dart:math';
import 'dart:typed_data';

/// Генерация звуков «на лету» (WAV, 16 бит, моно), чтобы приложению не нужны
/// были внешние аудиофайлы и интернет.
class SoundSynth {
  static const int _rate = 22050;

  /// Тихий мягкий фон (петля 8 секунд, бесшовная).
  static Uint8List ambientLoop() {
    const seconds = 8;
    final n = _rate * seconds;
    final samples = List<double>.filled(n, 0);
    // Частоты кратны 1/8 Гц — фаза в конце петли совпадает с началом.
    const voices = <List<double>>[
      [110.0, 0.0],
      [164.875, 1.3],
      [220.0, 2.6],
      [261.625, 3.9],
      [329.625, 5.2],
    ];
    for (var i = 0; i < n; i++) {
      final t = i / _rate;
      var v = 0.0;
      for (final voice in voices) {
        final env = 0.55 + 0.45 * sin(2 * pi * (t / seconds) + voice[1]);
        v += sin(2 * pi * voice[0] * t) * env * 0.12;
      }
      samples[i] = v;
    }
    return _wav(samples);
  }

  /// Светлый восходящий «колокольчик» — верный ответ.
  static Uint8List correct() {
    final buf = List<double>.filled((_rate * 1.0).round(), 0);
    _bell(buf, 523.25, 0.0, 0.5, 0.30);
    _bell(buf, 659.25, 0.12, 0.5, 0.30);
    _bell(buf, 783.99, 0.24, 0.7, 0.30);
    return _wav(buf);
  }

  /// Низкий мягкий тон — неверный ответ.
  static Uint8List wrong() {
    final buf = List<double>.filled((_rate * 0.9).round(), 0);
    _bell(buf, 196.0, 0.0, 0.5, 0.35);
    _bell(buf, 174.61, 0.18, 0.7, 0.35);
    return _wav(buf);
  }

  static void _bell(
    List<double> buf,
    double freq,
    double startSec,
    double durSec,
    double amp,
  ) {
    final start = (startSec * _rate).round();
    final len = (durSec * _rate).round();
    for (var i = 0; i < len && start + i < buf.length; i++) {
      final t = i / _rate;
      final attack = min(1.0, t / 0.01);
      final env = attack * exp(-4 * t / durSec);
      buf[start + i] += amp *
          env *
          (sin(2 * pi * freq * t) + 0.3 * sin(2 * pi * 2 * freq * t)) /
          1.3;
    }
  }

  static Uint8List _wav(List<double> samples) {
    final dataLen = samples.length * 2;
    final data = ByteData(44 + dataLen);
    void text(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    data.setUint32(4, 36 + dataLen, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, 1, Endian.little); // mono
    data.setUint32(24, _rate, Endian.little);
    data.setUint32(28, _rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    text(36, 'data');
    data.setUint32(40, dataLen, Endian.little);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
      data.setInt16(44 + i * 2, v, Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
