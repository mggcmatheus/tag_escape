import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Fundo animado com gradiente escuro e pontos de "estrelas" neon pulsando.
///
/// Leve o suficiente para rodar a 60 FPS atrás do jogo. Usado tanto nas telas
/// de menu quanto por trás do GameWidget (que tem fundo transparente).
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF161628), AppColors.background],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _StarsPainter(_controller.value),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t);

  final double t;
  static final Random _rng = Random(42); // seed fixa: estrelas estáveis.

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const count = 40;
    for (var i = 0; i < count; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      // Pulsação suave defasada por índice.
      final phase = (t * 2 * pi) + i;
      final alpha = (0.25 + 0.25 * (1 + sin(phase)) / 2).clamp(0.0, 1.0);
      final radius = 0.8 + (i % 3);
      paint.color = (i.isEven ? AppColors.neonCyan : AppColors.neonMagenta)
          .withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.t != t;
}
