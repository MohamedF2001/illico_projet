import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/shared_widget.dart';

// ─────────────────────────────────────────────────────────────
//  AdminAuthPage
//  Connexion UNIQUEMENT pour l'admin (pas d'inscription publique).
//  L'admin est créé en back-office ou via le premier register.
//  Design sobre, centré, adapté à une interface web.
// ─────────────────────────────────────────────────────────────

class AdminAuthPage extends ConsumerStatefulWidget {
  const AdminAuthPage({super.key});

  @override
  ConsumerState<AdminAuthPage> createState() => _AdminAuthPageState();
}

class _AdminAuthPageState extends ConsumerState<AdminAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

 /* Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: ref.read(authProvider.notifier).login(role: 'Admin', ...)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go('/admin/dashboard');
  }*/

  Future<void> _login() async {
    if (_formKey.currentState == null ||
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ok = await ref
          .read(authProvider.notifier)
          .login(
        role: 'Admin',
        email: _emailCtrl.text.trim(),
        motDePasse: _passCtrl.text,
      );

      if (!mounted) return;

      if (ok) {
        context.go('/admin/dashboard');
      } else {
        setState(() {
          _error = "Email ou mot de passe incorrect";
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
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // ── Panneau gauche décoratif ─────────────────────
          if (isDesktop)
            Container(
              width: 420,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF2D1B69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const _AdminBranding(),
            ),

          // ── Formulaire ───────────────────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
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
                          icon: const Icon(Icons.arrow_back_rounded,
                              size: 18, color: Color(0xFF6B7280)),
                          label: const Text('Retour',
                              style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                        const SizedBox(height: 24),

                        // Badge rôle
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF6B00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFF6B00)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.admin_panel_settings_rounded,
                                  size: 14, color: Color(0xFFFF6B00)),
                              SizedBox(width: 6),
                              Text('Espace Administrateur',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF6B00),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Connexion Admin',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Accédez au tableau de bord de gestion.',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 36),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              InputLabel(label: 'Adresse email'),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: inputDeco(
                                  hint: 'admin@illicodelivery.bj',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Email requis';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe
                              InputLabel(label: 'Mot de passe'),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                autofillHints: const [
                                  AutofillHints.password
                                ],
                                decoration: inputDeco(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Mot de passe requis';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 14),

                              // Se souvenir de moi
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                        () => _rememberMe = v ?? false),
                                    activeColor: const Color(0xFFFF6B00),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                  const Text('Se souvenir de moi',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280))),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Erreur
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          ErrorBanner(message: _error!),
                        ],

                        const SizedBox(height: 24),

                        PrimaryButton(
                          label: 'Se connecter',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          onPressed: _login,
                          color: const Color(0xFF1A1A2E),
                        ),

                        const SizedBox(height: 32),

                        // Sécurité
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.security_rounded,
                                  size: 16, color: Color(0xFF6B7280)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Connexion sécurisée · SSL/TLS · Accès restreint',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
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

// ── Branding panneau gauche admin ───────────────────────────
class _AdminBranding extends StatelessWidget {
  const _AdminBranding();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'ILLICO DELIVERY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Centre de\ncommande.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Accédez à tous les outils pour piloter\nvotre réseau de livraison.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          ...[
            (Icons.dashboard_rounded, 'Dashboard KPI en temps réel'),
            (Icons.manage_accounts_rounded, 'Gestion livreurs & validation'),
            (Icons.price_change_rounded, 'Tarification par zone & véhicule'),
            (Icons.receipt_long_rounded, 'Transactions & finances'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(item.$1, color: const Color(0xFFFF6B00), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
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
