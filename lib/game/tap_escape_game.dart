import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/audio_service.dart';
import '../state/shop_items.dart';
import 'components/obstacle.dart';
import 'components/obstacle_spawner.dart';
import 'components/player.dart';

/// Resultado de uma partida, entregue à camada de UI ao ocorrer Game Over.
class GameResult {
  const GameResult({required this.score, required this.survivalSeconds});

  final int score;
  final int survivalSeconds;

  /// Moedas ganhas com base na pontuação.
  int get coinsEarned => score ~/ GameConfig.pointsPerCoin;
}

typedef ScoreCallback = void Function(int score);
typedef MilestoneCallback = void Function(String message);
typedef GameOverCallback = void Function(GameResult result);

/// Jogo principal (Flame). Mantém o loop, a pontuação e o estado de partida.
///
/// A comunicação com o Flutter é feita por callbacks simples ([onScore],
/// [onMilestone], [onGameOver]) — o jogo não conhece widgets, o que mantém o
/// acoplamento baixo e facilita testes.
class TapEscapeGame extends FlameGame with HasCollisionDetection {
  TapEscapeGame({
    required this.skin,
    this.onScore,
    this.onMilestone,
    this.onGameOver,
  });

  SkinItem skin;
  ScoreCallback? onScore;
  MilestoneCallback? onMilestone;
  GameOverCallback? onGameOver;

  late Player _player;
  late ObstacleSpawner _spawner;

  double elapsedSeconds = 0;
  int _score = 0;
  int _milestoneIndex = 0;

  bool isRunning = false;
  bool isGameOver = false;

  int get score => _score;
  int get survivalSeconds => elapsedSeconds.floor();

  // Fundo transparente: o gradiente animado fica em um widget Flutter atrás.
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    _player = Player(position: size / 2, skin: skin);
    _spawner = ObstacleSpawner();
    addAll([_spawner, _player]);
  }

  /// Inicia uma nova partida do zero.
  void startGame() {
    _clearObstacles();
    elapsedSeconds = 0;
    _score = 0;
    _milestoneIndex = 0;
    isGameOver = false;
    isRunning = true;
    _player.position = size / 2;
    _player.velocity.setZero();
    onScore?.call(0);
  }

  /// Processa um toque na tela (coordenada local do GameWidget).
  void handleTap(Vector2 position) {
    if (!isRunning) return;
    _player.dashTowards(position);
    AudioService.instance.play(Sfx.tap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning) return;

    elapsedSeconds += dt;

    // Pontuação baseada no tempo sobrevivido.
    final newScore = (elapsedSeconds * GameConfig.pointsPerSecond).floor();
    if (newScore != _score) {
      _score = newScore;
      onScore?.call(_score);
      _checkMilestone();
    }
  }

  void _checkMilestone() {
    final milestones = ScoreMilestones.milestones;
    if (_milestoneIndex >= milestones.length) return;
    final next = milestones[_milestoneIndex];
    if (_score >= next.key) {
      _milestoneIndex++;
      onMilestone?.call(next.value);
      AudioService.instance.play(Sfx.collect);
    }
  }

  /// Chamado pelo [Player] ao colidir com um obstáculo.
  void onPlayerHit() {
    if (!isRunning) return;
    isRunning = false;
    isGameOver = true;
    AudioService.instance.play(Sfx.hit);
    AudioService.instance.play(Sfx.gameOver);
    onGameOver?.call(
      GameResult(score: _score, survivalSeconds: survivalSeconds),
    );
  }

  /// Revive o jogador (após assistir rewarded). Limpa a tela e dá um curto
  /// período de invulnerabilidade para evitar morte imediata.
  void revive() {
    _clearObstacles();
    _player.position = size / 2;
    _player.velocity.setZero();
    _player.grantInvulnerability(2.0);
    isGameOver = false;
    isRunning = true;
  }

  void _clearObstacles() {
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
  }

  /// Troca a skin da esfera em tempo real.
  void applySkin(SkinItem newSkin) {
    skin = newSkin;
    _player.updateSkin(newSkin);
  }
}
