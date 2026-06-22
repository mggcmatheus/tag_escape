import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/player_progress.dart';

/// Exibe o saldo atual de moedas do jogador, reagindo a mudanças.
class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.select<PlayerProgress, int>((p) => p.coins);
    return Container(
      key: const Key('coin-display'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonYellow, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on,
              color: AppColors.neonYellow, size: 20),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: AppColors.neonYellow,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
