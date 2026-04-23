import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/shared_widget.dart';

// ─────────────────────────────────────────────────────────────
//  PointAuthPage
//  Deux onglets : Se connecter / Inscrire mon point
//  Inscription : Infos du point + adresse + contact
//  Compte en attente d'activation admin après inscription
// ─────────────────────────────────────────────────────────────

class PointAuthPage extends ConsumerStatefulWidget {
  const PointAuthPage({super.key});

  @override
  ConsumerState<PointAuthPage> createState() => _PointAuthPageState();
}

class _PointAuthPageState extends ConsumerState<PointAuthPage>
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
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // Panneau gauche (desktop)
          if (isDesktop)
            Container(
              width: 380,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F1D96)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const _PointBranding(),
            ),

          // Formulaire
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : 24,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Retour
                        TextButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                          label: const Text(
                            'Retour',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF7C3AED).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.store_rounded,
                                size: 14,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Espace Point ILLICO',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Point ILLICO',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Gérez votre point de collecte et de livraison.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: TabBar(
                            controller: _tabs,
                            indicator: BoxDecoration(
                              color: const Color(0xFF7C3AED),
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
                              Tab(text: 'Inscrire mon point'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        SizedBox(
                          height: 600,
                          child: TabBarView(
                            controller: _tabs,
                            children: const [
                              _PointLoginTab(),
                              _PointRegisterTab(),
                            ],
                          ),
                        ),
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
}

// ════════════════════════════════════════════════════════════
//  ONGLET CONNEXION POINT
// ════════════════════════════════════════════════════════════

class _PointLoginTab extends ConsumerStatefulWidget {
  const _PointLoginTab();

  @override
  ConsumerState<_PointLoginTab> createState() => _PointLoginTabState();
}

class _PointLoginTabState extends ConsumerState<_PointLoginTab> {
  final _formKey = GlobalKey<FormState>();
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

  /*Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref
          .read(authProvider.notifier)
          .login(
        role: 'PointIllico',
        telephone: _phoneCtrl.text.trim(),
        motDePasse: _passCtrl.text,
      );

      if (!mounted) return;

      if (ok) {
        context.go('/point/colis');
      } else {
        setState(() {
          _error = "Numéro ou mot de passe incorrect";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Une erreur est survenue";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }*/

  /*Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref.read(authProvider.notifier).login(
        role: 'PointIllico',
        telephone: _phoneCtrl.text.trim(),
        motDePasse: _passCtrl.text,
      );

      if (!mounted) return;

      if (!ok) {
        final error = ref.read(authProvider).error;

        setState(() {
          _error = error != null
              ? "Compte en attente d'activation"
              : "Numéro ou mot de passe incorrect";
        });
      }

      final user = ref.read(authProvider).user;

      // 🔥 CAS: compte pas activé
      if (user != null &&
          user.role == 'PointIllico' &&
          user.actif == false) {
        setState(() {
          _error = null;
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Compte en attente"),
            content: const Text(
              "Votre compte Point ILLICO est en attente d’activation par l’administrateur.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
        return;
      }

      context.go('/point/colis');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Une erreur est survenue";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }*/

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref.read(authProvider.notifier).login(
        role: 'PointIllico',
        telephone: _phoneCtrl.text.trim(),
        motDePasse: _passCtrl.text,
      );

      if (!mounted) return;

      if (ok) {
        context.go('/point/colis');
        return;
      }

      // 🔥 Récupère l'erreur depuis le provider
      final error = ref.read(authProvider).error;

      // 👉 CAS : compte non activé
      if (error != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.pending_actions_rounded, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Text('Activation requise'),
              ],
            ),
            content: const Text(
              "Votre compte est en attente de validation par l'administrateur.\n\n"
                  "Vous recevrez une notification dès activation.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Compris'),
              ),
            ],
          ),
        );

        return; // 🔥 STOP ici → pas de navigation
      }

      // 👉 mauvais login
      setState(() {
        _error = "Numéro ou mot de passe incorrect";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Une erreur est survenue";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputLabel(label: 'Numéro de téléphone'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: inputDeco(
                hint: '+229 97 12 34 56',
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Numéro requis';
                }
                return null;
              },
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
              onFieldSubmitted: (_) => _login(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Accéder à mon espace',
              icon: Icons.store_rounded,
              isLoading: _isLoading,
              onPressed: _login,
              color: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Votre point doit être activé par l\'administrateur avant la première connexion.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ONGLET INSCRIPTION POINT ILLICO
// ════════════════════════════════════════════════════════════

class _PointRegisterTab extends ConsumerStatefulWidget {
  const _PointRegisterTab();

  @override
  ConsumerState<_PointRegisterTab> createState() => _PointRegisterTabState();
}

class _PointRegisterTabState extends ConsumerState<_PointRegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _success = false;
  String? _error;
  String _zone = 'Cotonou';

  final _zones = ['Cotonou', 'Abomey-Calavi', 'Godomey', 'Calavi', 'Autre'];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /*Future<void> _register() async {
    if (_nomCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _adresseCtrl.text.isEmpty) {
      setState(() => _error = 'Tous les champs obligatoires sont requis.');
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
      _isLoading = true;
      _error = null;
    });

    // TODO: authRepo.registerPoint(body: {...})
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _success = true;
    });
  }*/

  /*Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nomCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _adresseCtrl.text.isEmpty) {
      setState(() => _error = 'Tous les champs obligatoires sont requis.');
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
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref
          .read(authProvider.notifier)
          .registerPointIllico(
        nom: _nomCtrl.text.trim(),
        telephone: _phoneCtrl.text.trim(),
        motDePasse: _passCtrl.text,
        adresse: _adresseCtrl.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        setState(() => _success = true);
      } else {
        setState(() {
          _error = "Impossible de créer le point";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Une erreur est survenue";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }*/

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref
          .read(authProvider.notifier)
          .registerPointIllico(
        nom: _nomCtrl.text.trim(),
        telephone: _phoneCtrl.text.trim(),
        motDePasse: _passCtrl.text,
        adresse: _adresseCtrl.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        setState(() => _success = true);
      } else {
        setState(() {
          _error = "Impossible de créer le point";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Une erreur est survenue";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessPoint(nom: _nomCtrl.text);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Infos du point ─────────────────────────────
            const Text(
              'Informations du point',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 14),

            InputLabel(label: 'Nom du point *'),
            TextFormField(
              controller: _nomCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: inputDeco(
                hint: 'Point ILLICO Haie Vive',
                icon: Icons.store_outlined,
              ),
            ),
            const SizedBox(height: 14),

            InputLabel(label: 'Adresse complète *'),
            TextFormField(
              controller: _adresseCtrl,
              decoration: inputDeco(
                hint: 'Rue 123, Quartier, Ville',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 14),

            InputLabel(label: 'Zone'),
            DropdownButtonFormField<String>(
              initialValue: _zone,
              decoration: inputDeco(hint: '', icon: Icons.map_outlined),
              items: _zones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (v) => setState(() => _zone = v ?? _zone),
            ),
            const SizedBox(height: 14),

            InputLabel(label: 'Description (optionnel)'),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 2,
              decoration: inputDeco(
                hint: 'Horaires, spécialités, accès…',
                icon: Icons.notes_outlined,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // ── Accès au compte ────────────────────────────
            const Text(
              'Accès au compte',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 14),

            InputLabel(label: 'Téléphone *'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: inputDeco(
                hint: '+229 97 12 34 56',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputLabel(label: 'Mot de passe *'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: inputDeco(
                          hint: '6 caractères min.',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: const Color(0xFF6B7280),
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputLabel(label: 'Confirmer *'),
                      TextFormField(
                        controller: _confirmPassCtrl,
                        obscureText: _obscure,
                        decoration: inputDeco(
                          hint: 'Même mot de passe',
                          icon: Icons.lock_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Soumettre ma demande',
              icon: Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _register,
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Votre dossier sera examiné sous 48h.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Succès inscription point ────────────────────────────────
class _SuccessPoint extends StatelessWidget {
  final String nom;
  const _SuccessPoint({required this.nom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: Color(0xFF7C3AED),
              size: 42,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Demande envoyée !',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"$nom"\nEst en attente d\'activation par l\'équipe ILLICO.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              children: [
                _CheckItem(text: 'Dossier examiné sous 48h'),
                _CheckItem(text: 'Notification SMS à l\'activation'),
                _CheckItem(text: 'Accès à votre tableau de bord ensuite'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined, color: Color(0xFF6B7280)),
            label: const Text(
              'Retour à l\'accueil',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Branding point illico ───────────────────────────────────
class _PointBranding extends StatelessWidget {
  const _PointBranding();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Devenez un\nPoint ILLICO.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Rejoignez notre réseau de points de collecte et générez des revenus supplémentaires.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          ...[
            (Icons.inventory_2_outlined, 'Réceptionnez et remettez des colis'),
            (Icons.payments_outlined, 'Commissions sur chaque transaction'),
            (Icons.notifications_outlined, 'Alertes automatiques de retard'),
            (Icons.bar_chart_rounded, 'Suivi de vos revenus en temps réel'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(item.$1, color: Colors.white.withOpacity(0.9), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget succès commun ────────────────────────────────────
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
            color: Color(0xFF7C3AED),
            size: 17,
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
