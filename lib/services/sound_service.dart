import 'package:audioplayers/audioplayers.dart';

/// Воспроизводит короткие звуковые эффекты игры.
/// Отдельный AudioPlayer не прерывает фоновую музыку.
class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/lwl_sound.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      // Ошибка звука не должна останавливать игру.
    }
  }
  static Future<void> playBuying() async {
    try {
      await _player.stop();

      await _player.play(
        AssetSource('audio/buying_sound.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      // Ошибка звука не должна ломать покупку.
    }
  }
  static Future<void> playEating() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/eating_sound.mp3'),
        volume: 1.0,
      );
    } catch (_) {}
  }
}
