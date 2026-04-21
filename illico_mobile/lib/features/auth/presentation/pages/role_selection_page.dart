import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────
//  RoleSelectionPage
//  Premier écran affiché à un utilisateur non connecté.
//  Il choisit son profil → redirigé vers le bon flow d'auth.
// ─────────────────────────────────────────────────────────────

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ── Logo ───────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ILLICO',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
              const Text(
                'DELIVERY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFFF6B00),
                  letterSpacing: 10,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Livré. Maintenant.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white38,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(),

              // ── Titre ──────────────────────────────────────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Je suis…',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choisissez votre profil pour continuer',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 32),

              // ── Client ─────────────────────────────────────
              _RoleCard(
                icon: Icons.person_rounded,
                emoji: '👤',
                title: 'Client',
                subtitle: 'Commander et suivre mes livraisons',
                features: const [
                  'Livraison express ou Point ILLICO',
                  'Suivi temps réel de mon livreur',
                  'Historique & factures',
                ],
                gradient: const [Color(0xFFFF6B00), Color(0xFFE05A00)],
                onTap: () => context.go('/auth/client'),
              ),
              const SizedBox(height: 16),

              // ── Livreur ────────────────────────────────────
              _RoleCard(
                icon: Icons.two_wheeler_rounded,
                emoji: '🚴',
                title: 'Livreur',
                subtitle: 'Gérer mes missions et mes gains',
                features: const [
                  'Recevoir des missions en temps réel',
                  'Navigation GPS intégrée',
                  'Suivi de mes revenus & commissions',
                ],
                gradient: const [Color(0xFF1A1A2E), Color(0xFF2D2D5E)],
                borderColor: const Color(0xFF4A4A8A),
                onTap: () => context.go('/auth/livreur'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget carte rôle ───────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final List<String> features;
  final List<Color> gradient;
  final Color? borderColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.gradient,
    required this.onTap,
    this.borderColor,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.borderColor ?? Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.emoji} ${widget.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.features.map(
                          (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
