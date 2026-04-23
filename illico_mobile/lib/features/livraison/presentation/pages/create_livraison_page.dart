import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../providers/livraison_provider.dart';

class CreateLivraisonPage extends ConsumerStatefulWidget {
  const CreateLivraisonPage({super.key});

  @override
  ConsumerState<CreateLivraisonPage> createState() => _CreateLivraisonPageState();
}

class _CreateLivraisonPageState extends ConsumerState<CreateLivraisonPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMode;
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ILLICO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comment préférez\nvous recevoir ?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choisissez la vitesse ou l\'économie',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // ── Mode Selection ──────────────────────────
              _ModeCard(
                title: 'Livraison Express',
                subtitle: 'Directement à votre porte en moins de 30 minutes',
                footer: 'Arrivée estimée 14:45',
                badgeText: 'Le plus rapide',
                badgeColor: const Color(0xFFFFD5A1),
                isSelected: _selectedMode == 'express',
                onTap: () => setState(() => _selectedMode = 'express'),
                iconColor: const Color(0xFFF7B97D),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                title: 'Point ILLICO',
                subtitle: 'Directement à votre porte en moins de 30 minutes', // Copy from screenshot
                footer: 'À 450m . Pharmacie',
                badgeText: '-30% Réduction',
                badgeColor: const Color(0xFF8BB3FF),
                isSelected: _selectedMode == 'point',
                onTap: () => setState(() => _selectedMode = 'point'),
                iconColor: const Color(0xFF86A8E7),
                borderColor: const Color(0xFF3366FF),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _selectedMode == null ? null : () {
                  // Normalement on passerait à l'étape suivante (adresses, etc.)
                  // Ici on simule une création simplifiée ou on va vers une page de détails
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirmer le mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String footer;
  final String badgeText;
  final Color badgeColor;
  final Color iconColor;
  final Color? borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.badgeText,
    required this.badgeColor,
    required this.iconColor,
    this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? (borderColor ?? AppColors.primary)
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              footer,
              style: TextStyle(
                color: borderColor ?? AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
