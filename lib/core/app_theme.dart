import 'package:flutter/material.dart';

/// Paleta neon sobre fundo escuro usada em todo o app.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A12);
  static const Color surface = Color(0xFF14141F);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFFF2E97);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonYellow = Color(0xFFFFE600);
  static const Color neonPurple = Color(0xFFB14BFF);
  static const Color danger = Color(0xFFFF3B57);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8A8AA3);
}

/// Tema central do app (Material 3, dark).
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonMagenta,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'RobotoMono',
      ),
    );
  }
}

/// Sombra/brilho neon reutilizável.
List<BoxShadow> neonGlow(Color color, {double blur = 18, double spread = 1}) {
  return [
    BoxShadow(
      color: color.withOpacity(0.65),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];
}
