import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/missions_controller.dart';
import '../state/player_progress.dart';
import '../widgets/animated_background.dart';
import '../widgets/coin_display.dart';

/// Tela de missões diárias com progresso e resgate de recompensa.
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  void initState() {
    super.initState();
    // Garante reset diário ao abrir a tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionsController>().refreshDayIfNeeded();
    });
  }

  Future<void> _claim(Mission m) async {
    final missions = context.read<MissionsController>();
    final progress = context.read<PlayerProgress>();
    final reward = missions.claim(m.id);
    if (reward > 0) {
      await progress.addCoins(reward);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+$reward moedas!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<MissionsController>().missions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MISSÕES DIÁRIAS'),
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
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: missions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _MissionTile(
              mission: missions[i],
              onClaim: () => _claim(missions[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, required this.onClaim});

  final Mission mission;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = mission.completed && !mission.claimed;
    return Container(
      key: Key('mission-${mission.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.claimed
              ? AppColors.textMuted
              : (canClaim ? AppColors.neonGreen : AppColors.neonCyan),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mission.description,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mission.fraction,
              minHeight: 8,
              backgroundColor: AppColors.background,
              color: canClaim ? AppColors.neonGreen : AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mission.progress.clamp(0, mission.target)}/${mission.target}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              _trailing(canClaim),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trailing(bool canClaim) {
    if (mission.claimed) {
      return const Text('RESGATADA',
          style: TextStyle(color: AppColors.textMuted));
    }
    if (canClaim) {
      return ElevatedButton(
        key: Key('mission-claim-${mission.id}'),
        onPressed: onClaim,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: AppColors.background,
        ),
        child: Text('RESGATAR +${mission.reward}'),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on,
            color: AppColors.neonYellow, size: 16),
        const SizedBox(width: 4),
        Text('${mission.reward}',
            style: const TextStyle(color: AppColors.neonYellow)),
      ],
    );
  }
}
