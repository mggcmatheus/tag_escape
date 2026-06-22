import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Botão com estilo neon (borda brilhante sobre fundo escuro).
///
/// Possui `data-testid` equivalente via [Key] para automações de teste
/// (Playwright/integração). Passe [testId] para identificar o botão.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.neonCyan,
    this.icon,
    this.testId,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final String? testId;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      key: testId != null ? Key(testId!) : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: onPressed == null ? null : neonGlow(color, blur: 14),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              color: onPressed == null ? AppColors.textMuted : color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }
}
