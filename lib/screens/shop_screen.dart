import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/player_progress.dart';
import '../state/shop_items.dart';
import '../widgets/animated_background.dart';
import '../widgets/coin_display.dart';

/// Loja de skins/cores compráveis com moedas do jogo.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Future<void> _onTapSkin(BuildContext context, SkinItem skin) async {
    final progress = context.read<PlayerProgress>();
    final messenger = ScaffoldMessenger.of(context);

    if (progress.ownsSkin(skin.id)) {
      await progress.selectSkin(skin.id);
      messenger.showSnackBar(
        SnackBar(content: Text('Skin "${skin.name}" equipada!')),
      );
      return;
    }

    final result = await progress.buySkin(skin.id);
    switch (result) {
      case PurchaseResult.success:
        await progress.selectSkin(skin.id);
        messenger.showSnackBar(
          SnackBar(content: Text('Comprou e equipou "${skin.name}"!')),
        );
      case PurchaseResult.notEnoughCoins:
        messenger.showSnackBar(
          const SnackBar(content: Text('Moedas insuficientes.')),
        );
      case PurchaseResult.alreadyOwned:
      case PurchaseResult.invalid:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<PlayerProgress>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOJA'),
        backgroundColor: Colors.transparent,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinDisplay()),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: ShopCatalog.skins.length,
            itemBuilder: (_, i) {
              final skin = ShopCatalog.skins[i];
              final owned = progress.ownsSkin(skin.id);
              final selected = progress.selectedSkinId == skin.id;
              return _SkinCard(
                skin: skin,
                owned: owned,
                selected: selected,
                onTap: () => _onTapSkin(context, skin),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  final SkinItem skin;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('shop-skin-${skin.id}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.neonGreen : skin.glowColor,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: neonGlow(skin.glowColor, blur: 10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pré-visualização da esfera.
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skin.color,
                boxShadow: neonGlow(skin.glowColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              skin.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _statusLabel(),
          ],
        ),
      ),
    );
  }

  Widget _statusLabel() {
    if (selected) {
      return const Text('EQUIPADA',
          style: TextStyle(
              color: AppColors.neonGreen, fontWeight: FontWeight.bold));
    }
    if (owned) {
      return const Text('EQUIPAR',
          style: TextStyle(color: AppColors.neonCyan));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on,
            color: AppColors.neonYellow, size: 16),
        const SizedBox(width: 4),
        Text('${skin.price}',
            style: const TextStyle(
                color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
