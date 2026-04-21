import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/shared_widget.dart';

// ─────────────────────────────────────────────────────────────
//  LivreurAuthPage
//  Deux onglets : Se connecter / Créer un compte
//  Inscription : Infos personnelles + Choix du véhicule
//  Compte en attente de validation admin après inscription
// ─────────────────────────────────────────────────────────────

class LivreurAuthPage extends ConsumerStatefulWidget {
  const LivreurAuthPage({super.key});

  @override
  ConsumerState<LivreurAuthPage> createState() => _LivreurAuthPageState();
}

class _LivreurAuthPageState extends ConsumerState<LivreurAuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(
              emoji: '🚴',
              title: 'Espace Livreur',
              subtitle: 'Gérez vos missions et vos gains',
              color: const Color(0xFF1A1A2E),
              onBack: () => context.go('/role'),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Se connecter'),
                  Tab(text: 'Devenir livreur'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [_LivreurLoginTab(), _LivreurRegisterTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ONGLET CONNEXION LIVREUR
// ════════════════════════════════════════════════════════════

class _LivreurLoginTab extends ConsumerStatefulWidget {
  const _LivreurLoginTab();

  @override
  ConsumerState<_LivreurLoginTab> createState() => _LivreurLoginTabState();
}

class _LivreurLoginTabState extends ConsumerState<_LivreurLoginTab> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Tous les champs sont requis.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: ref.read(authProvider.notifier).login(role: 'Livreur', ...)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go('/livreur/missions');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Content de vous revoir 👋',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Des nouvelles missions vous attendent.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 28),

          InputLabel(label: 'Numéro de téléphone'),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: inputDeco(
              hint: '+229 97 12 34 56',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 16),

          InputLabel(label: 'Mot de passe'),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: inputDeco(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error!),
          ],

          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Se connecter',
            isLoading: _isLoading,
            onPressed: _login,
            color: const Color(0xFF1A1A2E),
          ),

          const SizedBox(height: 20),

          // Avertissement compte en attente
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF007AFF).withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF007AFF), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre compte doit être validé par un administrateur avant la première connexion.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF007AFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ONGLET INSCRIPTION LIVREUR
// ════════════════════════════════════════════════════════════

class _LivreurRegisterTab extends ConsumerStatefulWidget {
  const _LivreurRegisterTab();

  @override
  ConsumerState<_LivreurRegisterTab> createState() =>
      _LivreurRegisterTabState();
}

class _LivreurRegisterTabState extends ConsumerState<_LivreurRegisterTab> {
  int _step = 0; // 0 = infos perso, 1 = véhicule, 2 = confirmation
  bool _isLoading = false;
  String? _error;

  final _nomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscure = true;
  String? _selectedVehiculeId;
  String? _selectedVehiculeLabel;

  // Véhicules disponibles (idéalement chargés depuis l'API)
  final _vehicules = const [
    _VehiculeOption(
      id: 'v1',
      type: 'velo',
      label: 'Vélo',
      icon: Icons.pedal_bike_rounded,
      description: 'Livraisons légères < 10 kg',
      color: Color(0xFF00C896),
    ),
    _VehiculeOption(
      id: 'v2',
      type: 'moto',
      label: 'Moto',
      icon: Icons.two_wheeler_rounded,
      description: 'Livraisons urbaines rapides',
      color: Color(0xFFFF6B00),
    ),
    _VehiculeOption(
      id: 'v3',
      type: 'tricycle',
      label: 'Tricycle',
      icon: Icons.electric_rickshaw_rounded,
      description: 'Colis volumineux jusqu\'à 50 kg',
      color: Color(0xFF007AFF),
    ),
    _VehiculeOption(
      id: 'v4',
      type: 'voiture',
      label: 'Voiture',
      icon: Icons.directions_car_rounded,
      description: 'Confort & polyvalence',
      color: Color(0xFF1A1A2E),
    ),
    _VehiculeOption(
      id: 'v5',
      type: 'camionnette',
      label: 'Camionnette',
      icon: Icons.local_shipping_rounded,
      description: 'Grandes quantités > 100 kg',
      color: Color(0xFF9333EA),
    ),
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_step == 0) {
      if (_nomCtrl.text.trim().isEmpty ||
          _phoneCtrl.text.trim().isEmpty ||
          _passCtrl.text.isEmpty) {
        setState(() => _error = 'Tous les champs sont requis.');
        return;
      }
      if (_passCtrl.text.length < 6) {
        setState(() => _error = 'Mot de passe : 6 caractères minimum.');
        return;
      }
      if (_passCtrl.text != _confirmPassCtrl.text) {
        setState(() => _error = 'Les mots de passe ne correspondent pas.');
        return;
      }
      setState(() {
        _error = null;
        _step = 1;
      });
    } else if (_step == 1) {
      if (_selectedVehiculeId == null) {
        setState(() => _error = 'Choisissez votre type de véhicule.');
        return;
      }
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: appeler authRepo.registerLivreur(body: {...})
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
        _step = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (_step < 2)
            StepIndicator(
              steps: const ['Informations', 'Véhicule'],
              currentStep: _step,
              color: const Color(0xFF1A1A2E),
            ),
          const SizedBox(height: 24),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: switch (_step) {
                0 => _StepLivreurInfo(
                  nomCtrl: _nomCtrl,
                  phoneCtrl: _phoneCtrl,
                  passCtrl: _passCtrl,
                  confirmPassCtrl: _confirmPassCtrl,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                ),
                1 => _StepVehicule(
                  vehicules: _vehicules,
                  selected: _selectedVehiculeId,
                  onSelect: (id, label) => setState(() {
                    _selectedVehiculeId = id;
                    _selectedVehiculeLabel = label;
                  }),
                ),
                _ => _StepLivreurSuccess(nom: _nomCtrl.text),
              },
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error!),
          ],

          if (_step < 2) ...[
            const SizedBox(height: 24),
            PrimaryButton(
              label: _step == 0 ? 'Continuer' : 'Soumettre ma candidature',
              icon: _step == 0
                  ? Icons.arrow_forward_rounded
                  : Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _nextStep,
              color: const Color(0xFF1A1A2E),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Étape info livreur ──────────────────────────────────────
class _StepLivreurInfo extends StatelessWidget {
  final TextEditingController nomCtrl, phoneCtrl, passCtrl, confirmPassCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _StepLivreurInfo({
    required this.nomCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vos informations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Renseignez vos données personnelles.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        InputLabel(label: 'Nom complet *'),
        TextFormField(
          controller: nomCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: inputDeco(
            hint: 'Jean Dossou',
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 14),
        InputLabel(label: 'Téléphone *'),
        TextFormField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: inputDeco(
            hint: '+229 97 12 34 56',
            icon: Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 14),
        InputLabel(label: 'Mot de passe *'),
        TextFormField(
          controller: passCtrl,
          obscureText: obscure,
          decoration: inputDeco(
            hint: '6 caractères minimum',
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: const Color(0xFF6B7280),
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        const SizedBox(height: 14),
        InputLabel(label: 'Confirmer le mot de passe *'),
        TextFormField(
          controller: confirmPassCtrl,
          obscureText: obscure,
          decoration: inputDeco(
            hint: 'Même mot de passe',
            icon: Icons.lock_outline,
          ),
        ),
      ],
    );
  }
}

// ── Étape véhicule ──────────────────────────────────────────
class _StepVehicule extends StatelessWidget {
  final List<_VehiculeOption> vehicules;
  final String? selected;
  final void Function(String id, String label) onSelect;

  const _StepVehicule({
    required this.vehicules,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre véhicule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choisissez votre type de véhicule principal.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 20),
        ...vehicules.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSelect(v.id, v.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected == v.id
                      ? v.color.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected == v.id ? v.color : const Color(0xFFE5E7EB),
                    width: selected == v.id ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: v.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(v.icon, color: v.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: selected == v.id
                                  ? v.color
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            v.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected == v.id)
                      Icon(
                        Icons.check_circle_rounded,
                        color: v.color,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Confirmation inscription livreur ────────────────────────
class _StepLivreurSuccess extends StatelessWidget {
  final String nom;
  const _StepLivreurSuccess({required this.nom});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_empty_rounded,
            color: Color(0xFFFF9500),
            size: 42,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Candidature envoyée !',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Merci ${nom.split(' ').first} 🙌\nVotre dossier est en cours de traitement par notre équipe.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Column(
            children: [
              _CheckItem(text: 'Votre compte sera validé sous 24h'),
              _CheckItem(text: 'Vous recevrez une notification SMS'),
              _CheckItem(text: 'Vous pourrez alors vous connecter'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => context.go('/role'),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6B7280)),
          label: const Text(
            'Retour à l\'accueil',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF00C896),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class véhicule ────────────────────────────────────
class _VehiculeOption {
  final String id, type, label, description;
  final IconData icon;
  final Color color;

  const _VehiculeOption({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}
