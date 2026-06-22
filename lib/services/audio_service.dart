import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Tipos de efeito sonoro do jogo.
enum Sfx { tap, collect, hit, gameOver }

/// Serviço de áudio para efeitos sonoros curtos.
///
/// Usa um pool simples de [AudioPlayer] para permitir sons sobrepostos sem
/// cortar o efeito anterior. Respeita a flag de áudio ligado/desligado.
///
/// Os arquivos devem existir em `assets/audio/` (ver pubspec). Se um arquivo
/// estiver ausente, o erro é engolido para nunca quebrar o gameplay.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  static const Map<Sfx, String> _files = {
    Sfx.tap: 'audio/tap.wav',
    Sfx.collect: 'audio/collect.wav',
    Sfx.hit: 'audio/hit.wav',
    Sfx.gameOver: 'audio/game_over.wav',
  };

  // Pool de players reutilizáveis para evitar criação a cada toque.
  final List<AudioPlayer> _pool =
      List.generate(4, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  int _next = 0;

  Future<void> play(Sfx sfx) async {
    if (!_enabled) return;
    final asset = _files[sfx];
    if (asset == null) return;
    try {
      final player = _pool[_next];
      _next = (_next + 1) % _pool.length;
      await player.stop();
      await player.play(AssetSource(asset), volume: 0.7);
    } catch (e) {
      // Áudio nunca deve interromper o jogo.
      debugPrint('Falha ao tocar SFX $sfx: $e');
    }
  }

  Future<void> dispose() async {
    for (final p in _pool) {
      await p.dispose();
    }
  }
}
