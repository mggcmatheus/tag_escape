import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../state/shop_items.dart';
import '../tap_escape_game.dart';
import 'obstacle.dart';
import 'trail_particle.dart';

/// A esfera controlada pelo jogador.
///
/// Movimento: aplica-se um impulso de velocidade na direção do toque (dash);
/// a velocidade decai por atrito e uma força suave puxa a esfera de volta ao
/// centro, mantendo a ação concentrada no meio da tela.
class Player extends CircleComponent
    with CollisionCallbacks, HasGameReference<TapEscapeGame> {
  Player({required Vector2 position, required this.skin})
      : super(
          position: position,
          radius: GameConfig.playerRadius,
          anchor: Anchor.center,
        );

  SkinItem skin;

  /// Velocidade atual (px/s).
  final Vector2 velocity = Vector2.zero();

  /// Período de invulnerabilidade (usado logo após reviver).
  double _invulnerable = 0;
  bool get isInvulnerable => _invulnerable > 0;

  double _trailTimer = 0;
  final Random _rng = Random();

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: radius, anchor: Anchor.center));
    _applySkinPaint();
  }

  void _applySkinPaint() {
    paint = Paint()
      ..color = skin.color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  }

  /// Atualiza a skin em tempo de execução (ex.: trocou na loja).
  void updateSkin(SkinItem newSkin) {
    skin = newSkin;
    _applySkinPaint();
  }

  /// Aplica um impulso de dash na direção de [target] (coordenada de tela).
  void dashTowards(Vector2 target) {
    final dir = target - position;
    if (dir.length < 1) return;
    dir.normalize();
    velocity.setFrom(dir * GameConfig.dashSpeed);
  }

  /// Concede invulnerabilidade temporária (em segundos).
  void grantInvulnerability(double seconds) => _invulnerable = seconds;

  @override
  void update(double dt) {
    super.update(dt);

    if (_invulnerable > 0) _invulnerable -= dt;

    // Atrito linear: faz o dash decair em ~0.15s, virando um movimento curto.
    velocity.scale(max(0.0, 1.0 - 9.0 * dt));

    // Força suave de retorno ao centro.
    final center = game.size / 2;
    final toCenter = center - position;
    if (toCenter.length > radius) {
      velocity.add(toCenter.normalized() * (GameConfig.recenterPull * dt));
    }

    position.add(velocity * dt);

    // Mantém a esfera dentro dos limites da tela.
    position.x = position.x.clamp(radius, game.size.x - radius);
    position.y = position.y.clamp(radius, game.size.y - radius);

    _maybeEmitTrail(dt);
  }

  /// Emite partículas de rastro quando a skin tem rastro e a esfera se move.
  void _maybeEmitTrail(double dt) {
    if (!skin.trail) return;
    _trailTimer -= dt;
    if (_trailTimer > 0 || velocity.length < 40) return;
    _trailTimer = 0.02;
    parent?.add(
      TrailParticle(
        position: position.clone(),
        radius: radius * (0.5 + _rng.nextDouble() * 0.3),
        color: skin.glowColor,
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Obstacle && !isInvulnerable) {
      game.onPlayerHit();
    }
  }
}
