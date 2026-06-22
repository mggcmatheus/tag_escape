import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Define uma skin/cor comprável para a esfera do jogador.
///
/// Uma skin altera a cor base, a cor do brilho (glow) e, opcionalmente, ativa
/// um efeito visual extra (ex.: rastro de partículas mais intenso).
class SkinItem {
  const SkinItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    required this.glowColor,
    this.trail = false,
  });

  /// Identificador estável persistido no storage.
  final String id;
  final String name;

  /// Preço em moedas. 0 = grátis/inicial.
  final int price;

  final Color color;
  final Color glowColor;

  /// Se `true`, a esfera deixa um rastro de partículas mais forte.
  final bool trail;
}

/// Catálogo estático de skins disponíveis na loja.
///
/// Centralizado para que adicionar uma skin nova seja apenas inserir um item
/// aqui — nenhuma outra parte do código precisa mudar.
class ShopCatalog {
  ShopCatalog._();

  static const List<SkinItem> skins = [
    SkinItem(
      id: 'default',
      name: 'Ciano Clássico',
      price: 0,
      color: AppColors.neonCyan,
      glowColor: AppColors.neonCyan,
    ),
    SkinItem(
      id: 'magenta',
      name: 'Magenta Neon',
      price: 150,
      color: AppColors.neonMagenta,
      glowColor: AppColors.neonMagenta,
    ),
    SkinItem(
      id: 'green',
      name: 'Verde Radioativo',
      price: 250,
      color: AppColors.neonGreen,
      glowColor: AppColors.neonGreen,
    ),
    SkinItem(
      id: 'yellow',
      name: 'Amarelo Solar',
      price: 400,
      color: AppColors.neonYellow,
      glowColor: AppColors.neonYellow,
    ),
    SkinItem(
      id: 'purple_trail',
      name: 'Roxo Cometa',
      price: 700,
      color: AppColors.neonPurple,
      glowColor: AppColors.neonPurple,
      trail: true,
    ),
    SkinItem(
      id: 'rainbow_trail',
      name: 'Prisma (rastro)',
      price: 1200,
      color: Colors.white,
      glowColor: AppColors.neonCyan,
      trail: true,
    ),
  ];

  static SkinItem byId(String id) =>
      skins.firstWhere((s) => s.id == id, orElse: () => skins.first);
}
