import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/player_progress.dart';
import '../state/settings_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coin_display.dart';
import '../widgets/neon_button.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'missions_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

/// Tela inicial: título, recorde, saldo, navegação e banner de anúncio.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<PlayerProgress>();
    final settings = context.watch<SettingsController>();

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior: moedas + áudio.
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CoinDisplay(),
                    IconButton(
                      key: const Key('home-sound-toggle'),
                      icon: Icon(
                        settings.soundEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: AppColors.neonCyan,
                      ),
                      onPressed: () => context
                          .read<SettingsController>()
                          .toggleSound(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Título.
              const Text(
                'TAP',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neonCyan,
                  letterSpacing: 8,
                ),
              ),
              const Text(
                'ESCAPE',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neonMagenta,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'RECORDE: ${progress.highScore}',
                key: const Key('home-highscore-label'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),

              const Spacer(),

              // Botões de navegação.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    NeonButton(
                      label: 'JOGAR',
                      icon: Icons.play_arrow,
                      testId: 'home-play-button',
                      onPressed: () => _open(context, const GameScreen()),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            label: 'LOJA',
                            icon: Icons.store,
                            color: AppColors.neonGreen,
                            testId: 'home-shop-button',
                            onPressed: () =>
                                _open(context, const ShopScreen()),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: NeonButton(
                            label: 'MISSÕES',
                            icon: Icons.flag,
                            color: AppColors.neonYellow,
                            testId: 'home-missions-button',
                            onPressed: () =>
                                _open(context, const MissionsScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            label: 'RANKING',
                            icon: Icons.leaderboard,
                            color: AppColors.neonPurple,
                            testId: 'home-leaderboard-button',
                            onPressed: () =>
                                _open(context, const LeaderboardScreen()),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: NeonButton(
                            label: 'AJUSTES',
                            icon: Icons.settings,
                            color: AppColors.textMuted,
                            testId: 'home-settings-button',
                            onPressed: () =>
                                _open(context, const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Banner de anúncio na tela inicial.
              const BannerAdWidget(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
