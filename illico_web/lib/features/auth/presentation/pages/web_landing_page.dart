import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────
//  WebLandingPage
//  Page d'accueil du portail web ILLICO.
//  Deux entrées : Admin et Point ILLICO.
//  Design responsive : desktop 2 colonnes / mobile empilé.
// ─────────────────────────────────────────────────────────────

class WebLandingPage extends StatelessWidget {
  const WebLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Row(
        children: [
          // ── Panneau gauche (branding) ─────────────────────
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const _BrandingPanel(),
              ),
            ),

          // ── Panneau droit (sélection) ─────────────────────
          Expanded(
            flex: isDesktop ? 7 : 1,
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: const _SelectionPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Panneau de branding gauche ──────────────────────────────
class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ILLICO DELIVERY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Portail Professionnel',
                    style: TextStyle(
                      color: Color(0xFFFF6B00),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 50),

          // Titre
          const Text(
            'Gérez votre\nréseau de livraison.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilotez vos opérations, suivez vos colis\net analysez vos performances en temps réel.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 60),

          // Stats
          Row(
            children: [
              _BrandingStat(value: '1 200+', label: 'Livraisons/mois'),
              const SizedBox(width: 40),
              _BrandingStat(value: '28', label: 'Livreurs actifs'),
              const SizedBox(width: 40),
              _BrandingStat(value: '12', label: 'Points ILLICO'),
            ],
          ),

          const SizedBox(height: 60),

          // Témoignage
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '"ILLICO nous a permis de tripler notre volume de livraisons en 3 mois."',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('K',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kossi A.',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('Point ILLICO Haie Vive',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandingStat extends StatelessWidget {
  final String value;
  final String label;
  const _BrandingStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Panneau de sélection droit ──────────────────────────────
class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64 : 24,
          vertical: 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo (mobile uniquement)
              if (!isDesktop) ...[
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ILLICO DELIVERY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              const Text(
                'Accéder au portail',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choisissez votre espace professionnel',
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 40),

              // ── Admin ─────────────────────────────────────
              _WebPortalCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Administrateur',
                subtitle: 'Gestion complète de la plateforme',
                features: const [
                  'Dashboard KPI & statistiques',
                  'Gestion livreurs, tarifs, zones',
                  'Suivi financier & transactions',
                ],
                color: const Color(0xFF1A1A2E),
                accentColor: const Color(0xFFFF6B00),
                onTap: () => context.go('/auth/admin'),
              ),
              const SizedBox(height: 16),

              // ── Point ILLICO ──────────────────────────────
              _WebPortalCard(
                icon: Icons.store_rounded,
                title: 'Point ILLICO',
                subtitle: 'Gestion de votre point de collecte',
                features: const [
                  'Réceptionner et remettre des colis',
                  'Alertes et frais de stockage',
                  'Commissions et revenus',
                ],
                color: const Color(0xFF7C3AED),
                accentColor: const Color(0xFF7C3AED),
                onTap: () => context.go('/auth/point'),
              ),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 16),

              // Lien app mobile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smartphone_rounded,
                        color: Color(0xFF6B7280)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vous êtes client ou livreur ?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Téléchargez l\'application mobile ILLICO.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Télécharger',
                        style: TextStyle(color: Color(0xFFFF6B00)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Carte portail web ───────────────────────────────────────
class _WebPortalCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  const _WebPortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_WebPortalCard> createState() => _WebPortalCardState();
}

class _WebPortalCardState extends State<_WebPortalCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor
                  : const Color(0xFFE5E7EB),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(_hovered ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon,
                    color: widget.color, size: 26),
              ),
              const SizedBox(width: 16),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _hovered
                            ? widget.accentColor
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 13,
                                color:
                                    widget.accentColor.withOpacity(0.7)),
                            const SizedBox(width: 6),
                            Text(
                              f,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
              AnimatedSlide(
                duration: const Duration(milliseconds: 150),
                offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _hovered
                      ? widget.accentColor
                      : const Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
