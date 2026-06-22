import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Obstáculo que cruza a tela em linha reta a uma velocidade fixa.
///
/// É criado fora da tela e se move em direção ao centro (com leve variação),
/// removendo-se sozinho ao sair completamente da área visível para não
/// acumular componentes na memória.
class Obstacle extends CircleComponent with CollisionCallbacks {
  Obstacle({
    required Vector2 position,
    required this.velocity,
    required double radius,
    required this.bounds,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()..color = AppColors.danger,
        );

  /// Velocidade em px/s (direção + magnitude).
  final Vector2 velocity;

  /// Tamanho da área de jogo, usado para descartar quando sai da tela.
  final Vector2 bounds;

  @override
  Future<void> onLoad() async {
    // Hitbox circular para detecção de colisão precisa.
    add(CircleHitbox(radius: radius, anchor: Anchor.center));
    // Brilho neon: borda mais clara.
    paint
      ..color = AppColors.danger
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    // Descarta quando estiver bem fora da tela (margem de segurança).
    const margin = 80.0;
    if (position.x < -margin ||
        position.y < -margin ||
        position.x > bounds.x + margin ||
        position.y > bounds.y + margin) {
      removeFromParent();
    }
  }
}
