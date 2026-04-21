import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/formatters.dart';

class StatutBadge extends StatelessWidget {
  final String statut;
  const StatutBadge({super.key, required this.statut});

  Color get _color => switch (statut) {
    'livré' || 'retiré'          => AppColors.accent,
    'affecté' || 'receptionné'   => AppColors.info,
    'annulé' || 'échoué' || 'retourné' => AppColors.danger,
    'en_attente'                 => AppColors.warning,
    'en_ligne'                   => AppColors.accent,
    'hors_ligne'                 => AppColors.textSecondary,
    'en_mission'                 => AppColors.info,
    _                            => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(Formatters.statutLabel(statut),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
    );
  }
}
