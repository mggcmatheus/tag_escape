import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Pequena partícula de rastro que aparece atrás da esfera e desaparece
/// gradualmente. Usada como efeito visual (glow/rastro) das skins.
///
/// É deliberadamente leve: um único círculo que reduz opacidade e raio até
/// se autorremover, mantendo 60 FPS mesmo com várias na tela.
class TrailParticle extends CircleComponent {
  TrailParticle({
    required Vector2 position,
    required double radius,
    required this.color,
    this.life = 0.45,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()..color = color,
        );

  final Color color;

  /// Tempo de vida total em segundos.
  final double life;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / life).clamp(0.0, 1.0);
    if (t >= 1.0) {
      removeFromParent();
      return;
    }
    // Fade de opacidade e leve encolhimento ao longo da vida.
    paint.color = color.withOpacity((1.0 - t) * 0.6);
  }
}
