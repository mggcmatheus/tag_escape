import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/player_progress.dart';
import '../widgets/animated_background.dart';

/// Ranking local: Top 10 melhores pontuações salvas no dispositivo.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = context.watch<PlayerProgress>().leaderboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RANKING LOCAL'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: scores.isEmpty
              ? const Center(
                  child: Text(
                    'Jogue uma partida para\naparecer no ranking!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  key: const Key('leaderboard-list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: scores.length,
                  itemBuilder: (_, i) => _ScoreRow(rank: i + 1, score: scores[i]),
                ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.rank, required this.score});

  final int rank;
  final int score;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.neonYellow;
      case 2:
        return AppColors.neonCyan;
      case 3:
        return AppColors.neonMagenta;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rankColor, width: rank <= 3 ? 2 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$score',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          const Text('pts', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
