import 'dart:math';

import 'package:flame/components.dart';

import '../../core/constants.dart';
import '../tap_escape_game.dart';
import 'obstacle.dart';

/// Responsável por criar obstáculos ao longo do tempo, aumentando a
/// dificuldade de forma contínua (mais rápido e com menos intervalo conforme
/// o tempo de jogo cresce).
class ObstacleSpawner extends Component
    with HasGameReference<TapEscapeGame> {
  final Random _rng = Random();
  double _timeToNextSpawn = 0;

  /// Velocidade atual dos obstáculos em função do tempo decorrido.
  double get _currentSpeed => min(
        GameConfig.obstacleMaxSpeed,
        GameConfig.obstacleBaseSpeed +
            game.elapsedSeconds * GameConfig.obstacleSpeedRampPerSecond,
      );

  /// Intervalo atual entre spawns em função do tempo decorrido.
  double get _currentInterval => max(
        GameConfig.spawnIntervalMin,
        GameConfig.spawnIntervalStart -
            game.elapsedSeconds * GameConfig.spawnIntervalRampPerSecond,
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning) return;

    _timeToNextSpawn -= dt;
    if (_timeToNextSpawn <= 0) {
      _spawnObstacle();
      _timeToNextSpawn = _currentInterval;
    }
  }

  void _spawnObstacle() {
    final size = game.size;
    final center = size / 2;

    // Posição de origem: em um círculo ao redor (e fora) da tela.
    final spawnRadius = size.length / 2 + 40;
    final angle = _rng.nextDouble() * 2 * pi;
    final origin = center +
        Vector2(cos(angle), sin(angle)).scaled(spawnRadius);

    // Alvo: ponto próximo ao centro, com pequena variação para não ficar
    // sempre na mesma linha (mais imprevisível).
    final jitter = Vector2(
      (_rng.nextDouble() - 0.5) * size.x * 0.3,
      (_rng.nextDouble() - 0.5) * size.y * 0.3,
    );
    final target = center + jitter;

    final direction = (target - origin).normalized();
    final radius = GameConfig.obstacleMinRadius +
        _rng.nextDouble() *
            (GameConfig.obstacleMaxRadius - GameConfig.obstacleMinRadius);

    game.add(
      Obstacle(
        position: origin,
        velocity: direction * _currentSpeed,
        radius: radius,
        bounds: size,
      ),
    );
  }
}
