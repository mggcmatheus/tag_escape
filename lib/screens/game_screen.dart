import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/ad_manager.dart';
import '../core/app_theme.dart';
import '../game/tap_escape_game.dart';
import '../state/missions_controller.dart';
import '../state/player_progress.dart';
import '../widgets/animated_background.dart';
import '../widgets/neon_button.dart';

/// Tela que hospeda o jogo Flame e os overlays de HUD, pausa e game over.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final TapEscapeGame _game;

  // Notificadores para atualizar o HUD sem reconstruir a árvore inteira.
  final ValueNotifier<int> _score = ValueNotifier(0);
  final ValueNotifier<String?> _milestone = ValueNotifier(null);

  GameResult? _lastResult;
  bool _isNewRecord = false;
  bool _revivedOnce = false;
  bool _started = false;

  // Se a próxima partida deve exibir intersticial (definido no game over).
  bool _showInterstitialNext = false;

  @override
  void initState() {
    super.initState();
    final skin = context.read<PlayerProgress>().selectedSkin;
    _game = TapEscapeGame(
      skin: skin,
      onScore: (s) => _score.value = s,
      onMilestone: _showMilestone,
      onGameOver: _handleGameOver,
    );
  }

  @override
  void dispose() {
    _score.dispose();
    _milestone.dispose();
    super.dispose();
  }

  void _showMilestone(String message) {
    _milestone.value = message;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_milestone.value == message) _milestone.value = null;
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (!_started) {
      _started = true;
      _game.overlays.remove('start');
      _game.startGame();
      return;
    }
    _game.handleTap(details.localPosition.toVector2());
  }

  Future<void> _handleGameOver(GameResult result) async {
    final progress = context.read<PlayerProgress>();
    final missions = context.read<MissionsController>();

    _isNewRecord = await progress.registerGameResult(
      score: result.score,
      coinsEarned: result.coinsEarned,
    );
    missions.registerGameResult(
      score: result.score,
      survivalSeconds: result.survivalSeconds,
    );
    // Decide (e avança o contador) se a PRÓXIMA partida mostra intersticial.
    _showInterstitialNext = await progress.shouldShowInterstitialAndAdvance();

    if (!mounted) return;
    setState(() => _lastResult = result);
    _game.overlays.add('gameOver');
  }

  Future<void> _playAgain() async {
    _game.overlays.remove('gameOver');
    // Intersticial a cada N partidas (nunca em todas) — antes de reiniciar.
    if (_showInterstitialNext) {
      _showInterstitialNext = false;
      await AdManager.instance.showInterstitial();
    }
    _revivedOnce = false;
    _started = true;
    _score.value = 0;
    _milestone.value = null;
    _game.startGame();
  }

  Future<void> _watchAdToRevive() async {
    final shown = await AdManager.instance.showRewarded(
      onReward: () {
        _revivedOnce = true;
        _game.overlays.remove('gameOver');
        _game.revive();
      },
    );
    if (!shown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anúncio indisponível no momento.')),
      );
    }
  }

  void _goHome() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          child: GameWidget<TapEscapeGame>(
            game: _game,
            backgroundBuilder: (_) => const SizedBox.shrink(),
            initialActiveOverlays: const ['hud', 'start'],
            overlayBuilderMap: {
              'hud': (_, __) => _buildHud(),
              'start': (_, __) => _buildStart(),
              'gameOver': (_, __) => _buildGameOver(),
            },
          ),
        ),
      ),
    );
  }

  // --- Overlays --------------------------------------------------------------

  Widget _buildHud() {
    return SafeArea(
      child: Stack(
        children: [
          // Pontuação centralizada no topo.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ValueListenableBuilder<int>(
                valueListenable: _score,
                builder: (_, score, __) => Text(
                  '$score',
                  key: const Key('game-score-label'),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    shadows: [
                      Shadow(color: AppColors.neonCyan, blurRadius: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Toast de marco (milestone).
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: ValueListenableBuilder<String?>(
                valueListenable: _milestone,
                builder: (_, msg, __) => AnimatedOpacity(
                  opacity: msg == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    msg ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonYellow,
                      shadows: [
                        Shadow(color: AppColors.neonYellow, blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStart() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, color: AppColors.neonCyan, size: 64),
          SizedBox(height: 16),
          Text(
            'TOQUE PARA COMEÇAR',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toque para desviar dos obstáculos',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    final result = _lastResult;
    if (result == null) return const SizedBox.shrink();
    final progress = context.read<PlayerProgress>();
    final canRevive = !_revivedOnce && AdManager.instance.isRewardedReady;

    return Container(
      color: Colors.black.withOpacity(0.75),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          key: const Key('game-over-panel'),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.danger, width: 2),
            boxShadow: neonGlow(AppColors.danger),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isNewRecord)
                const Text(
                  'NOVO RECORDE!',
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                )
              else
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                '${result.score}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neonCyan,
                ),
              ),
              const Text('PONTOS', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Text(
                'Recorde: ${progress.highScore}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              Text(
                '+${result.coinsEarned} moedas',
                style: const TextStyle(
                  color: AppColors.neonYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Reviver com rewarded (apenas uma vez, se houver anúncio pronto).
              if (canRevive) ...[
                NeonButton(
                  label: 'ASSISTIR E REVIVER',
                  icon: Icons.play_circle_fill,
                  color: AppColors.neonGreen,
                  testId: 'game-over-revive-button',
                  onPressed: _watchAdToRevive,
                ),
                const SizedBox(height: 12),
              ],
              NeonButton(
                label: 'JOGAR NOVAMENTE',
                icon: Icons.refresh,
                testId: 'game-over-play-again-button',
                onPressed: _playAgain,
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'MENU',
                icon: Icons.home,
                color: AppColors.textMuted,
                testId: 'game-over-home-button',
                onPressed: _goHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Conversão utilitária de [Offset] para [Vector2] do Flame.
extension on Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}
