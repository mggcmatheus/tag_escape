import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/settings_controller.dart';
import '../widgets/animated_background.dart';

/// Configurações do jogo (áudio on/off + informações).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AJUSTES'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonCyan, width: 1.5),
                ),
                child: SwitchListTile(
                  key: const Key('settings-sound-switch'),
                  title: const Text('Áudio'),
                  subtitle: const Text('Efeitos sonoros do jogo'),
                  activeColor: AppColors.neonCyan,
                  value: settings.soundEnabled,
                  onChanged: (v) =>
                      context.read<SettingsController>().setSoundEnabled(v),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Tap Escape v1.0.0\nDesvie. Sobreviva. Bata o recorde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
