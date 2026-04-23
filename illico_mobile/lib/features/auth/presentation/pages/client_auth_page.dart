import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/shared_widget.dart';
// import 'package:illico_shared/illico_shared.dart';

// ─────────────────────────────────────────────────────────────
//  ClientAuthPage
//  Deux onglets : Se connecter / Créer un compte
//  Inscription en 3 étapes : Téléphone → OTP → Informations
// ─────────────────────────────────────────────────────────────

class ClientAuthPage extends ConsumerStatefulWidget {
  const ClientAuthPage({super.key});

  @override
  ConsumerState<ClientAuthPage> createState() => _ClientAuthPageState();
}

class _ClientAuthPageState extends ConsumerState<ClientAuthPage>
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
            // ── Header ───────────────────────────────────────
            AuthHeader(
              emoji: '👤',
              title: 'Espace Client',
              subtitle: 'Commander et suivre vos livraisons',
              color: const Color(0xFFFF6B00),
              onBack: () => context.go('/role'),
            ),

            // ── Tabs ─────────────────────────────────────────
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
                  color: const Color(0xFFFF6B00),
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
                  Tab(text: 'Créer un compte'),
                ],
              ),
            ),

            // ── Contenu ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [ClientLoginTab(), _ClientRegisterTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ONGLET CONNEXION CLIENT
// ════════════════════════════════════════════════════════════

class ClientLoginTab extends ConsumerStatefulWidget {
  const ClientLoginTab();

  @override
  ConsumerState<ClientLoginTab> createState() => _ClientLoginTabState();
}

class _ClientLoginTabState extends ConsumerState<ClientLoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: appeler ref.read(authProvider.notifier).login(...)
    final ok = await ref.read(authProvider.notifier).login(
      role: 'Client',
      telephone: _phoneCtrl.text.trim(),
      codePin: _pinCtrl.text,
    );
    if (ok && mounted) context.go('/home');

    // Simulation
    /*await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go('/home');*/
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Bienvenue 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Connectez-vous pour accéder à votre espace',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 28),

            // Téléphone
            InputLabel(label: 'Numéro de téléphone'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: inputDeco(
                hint: '+229 97 12 34 56',
                icon: Icons.phone_outlined,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Numéro requis';
                if (v.length < 8) return 'Numéro invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Code PIN
            InputLabel(label: 'Code PIN'),
            TextFormField(
              controller: _pinCtrl,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: inputDeco(
                hint: '● ● ● ●',
                icon: Icons.pin_outlined,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePin ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                counter: '',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'PIN requis';
                if (v.length < 4) return '4 à 6 chiffres';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Mot de passe oublié
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // TODO: reset PIN flow
                child: const Text(
                  'PIN oublié ?',
                  style: TextStyle(color: Color(0xFFFF6B00), fontSize: 13),
                ),
              ),
            ),

            // Erreur
            if (_error != null) ErrorBanner(message: _error!),

            const SizedBox(height: 8),

            // Bouton connexion
            PrimaryButton(
              label: 'Se connecter',
              isLoading: _isLoading,
              onPressed: _login,
            ),

            const SizedBox(height: 24),

            // Divider
            const OrDivider(),
            const SizedBox(height: 16),

            // Connexion sociale (optionnel)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Text('🌐', style: TextStyle(fontSize: 16)),
              label: const Text('Continuer avec Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ONGLET INSCRIPTION CLIENT (3 étapes)
// ════════════════════════════════════════════════════════════

class _ClientRegisterTab extends ConsumerStatefulWidget {
  const _ClientRegisterTab();

  @override
  ConsumerState<_ClientRegisterTab> createState() => _ClientRegisterTabState();
}

class _ClientRegisterTabState extends ConsumerState<_ClientRegisterTab> {
  // Étapes : 0 = téléphone, 1 = OTP, 2 = informations
  int _step = 0;
  bool _isLoading = false;
  String? _error;

  // Controllers
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  bool _obscurePin = true;
  String _typeClient = 'standard';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nomCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  // ── Étape 1 : envoi OTP ─────────────────────────────────
  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().length < 8) {
      setState(() => _error = 'Numéro de téléphone invalide.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: appeler authRepo.initClientRegister(telephone: ...)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _step = 1;
    });
  }

  // ── Étape 2 : vérification OTP ──────────────────────────
  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) {
      setState(() => _error = 'Entrez les 6 chiffres du code.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: vérifier OTP côté backend ou stocker pour l'étape finale
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
      _step = 2;
    });
  }

  // ── Étape 3 : création du compte ────────────────────────
  Future<void> _createAccount() async {
    if (_nomCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Nom requis.');
      return;
    }
    if (_pinCtrl.text.length < 4) {
      setState(() => _error = 'PIN de 4 à 6 chiffres requis.');
      return;
    }
    if (_pinCtrl.text != _confirmPinCtrl.text) {
      setState(() => _error = 'Les codes PIN ne correspondent pas.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: appeler authRepo.registerClient(body: {...})
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00C896),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compte créé !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenue ${_nomCtrl.text.split(' ').first} 🎉\nVotre compte est prêt.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Commencer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Indicateur d'étapes ─────────────────────────
          StepIndicator(
            steps: const ['Téléphone', 'Vérification', 'Informations'],
            currentStep: _step,
            color: const Color(0xFFFF6B00),
          ),
          const SizedBox(height: 28),

          // ── Contenu selon l'étape ───────────────────────
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
              child: _step == 0
                  ? _StepPhone(
                      controller: _phoneCtrl,
                      isLoading: _isLoading,
                      onNext: _sendOtp,
                    )
                  : _step == 1
                  ? _StepOtp(
                      phone: _phoneCtrl.text,
                      controller: _otpCtrl,
                      isLoading: _isLoading,
                      onNext: _verifyOtp,
                      onResend: _sendOtp,
                    )
                  : _StepInfo(
                      nomCtrl: _nomCtrl,
                      pinCtrl: _pinCtrl,
                      confirmPinCtrl: _confirmPinCtrl,
                      adresseCtrl: _adresseCtrl,
                      typeClient: _typeClient,
                      obscurePin: _obscurePin,
                      isLoading: _isLoading,
                      onToggleObscure: () =>
                          setState(() => _obscurePin = !_obscurePin),
                      onTypeChanged: (v) => setState(() => _typeClient = v),
                      onSubmit: _createAccount,
                    ),
            ),
          ),

          // ── Erreur ──────────────────────────────────────
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error!),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Étape 1 : Téléphone ─────────────────────────────────────
class _StepPhone extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onNext;

  const _StepPhone({
    required this.controller,
    required this.isLoading,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre numéro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Un code de vérification à 6 chiffres\nvous sera envoyé par SMS.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        InputLabel(label: 'Numéro de téléphone'),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofocus: true,
          decoration: inputDeco(
            hint: '+229 97 12 34 56',
            icon: Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '🔒 Votre numéro est uniquement utilisé pour la connexion.',
          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Envoyer le code',
          icon: Icons.send_rounded,
          isLoading: isLoading,
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ── Étape 2 : OTP ───────────────────────────────────────────
class _StepOtp extends StatelessWidget {
  final String phone;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onResend;

  const _StepOtp({
    required this.phone,
    required this.controller,
    required this.isLoading,
    required this.onNext,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Code de vérification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Entrez le code à 6 chiffres envoyé au\n$phone',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 32),

        // Champ OTP style grand
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 16,
            color: Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
        const SizedBox(height: 24),

        PrimaryButton(
          label: 'Vérifier',
          icon: Icons.verified_rounded,
          isLoading: isLoading,
          onPressed: onNext,
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton.icon(
            onPressed: onResend,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 16,
              color: Color(0xFFFF6B00),
            ),
            label: const Text(
              'Renvoyer le code',
              style: TextStyle(color: Color(0xFFFF6B00)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Étape 3 : Informations ──────────────────────────────────
class _StepInfo extends StatelessWidget {
  final TextEditingController nomCtrl;
  final TextEditingController pinCtrl;
  final TextEditingController confirmPinCtrl;
  final TextEditingController adresseCtrl;
  final String typeClient;
  final bool obscurePin;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;

  const _StepInfo({
    required this.nomCtrl,
    required this.pinCtrl,
    required this.confirmPinCtrl,
    required this.adresseCtrl,
    required this.typeClient,
    required this.obscurePin,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onTypeChanged,
    required this.onSubmit,
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
          'Dernière étape, complétez votre profil.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),

        InputLabel(label: 'Nom complet *'),
        TextFormField(
          controller: nomCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: inputDeco(
            hint: 'Koffi Mensah',
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 14),

        InputLabel(label: 'Code PIN (4 à 6 chiffres) *'),
        TextFormField(
          controller: pinCtrl,
          obscureText: obscurePin,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: inputDeco(
            hint: '● ● ● ●',
            icon: Icons.pin_outlined,
            suffix: IconButton(
              icon: Icon(
                obscurePin ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            counter: '',
          ),
        ),
        const SizedBox(height: 14),

        InputLabel(label: 'Confirmer le PIN *'),
        TextFormField(
          controller: confirmPinCtrl,
          obscureText: obscurePin,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: inputDeco(
            hint: '● ● ● ●',
            icon: Icons.pin_outlined,
            counter: '',
          ),
        ),
        const SizedBox(height: 14),

        InputLabel(label: 'Adresse (optionnel)'),
        TextFormField(
          controller: adresseCtrl,
          decoration: inputDeco(
            hint: 'Cotonou, Haie Vive, Rue 123',
            icon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: 16),

        // Type de client
        InputLabel(label: 'Type de compte'),
        Row(
          children: [
            TypeChip(
              label: 'Standard',
              icon: Icons.person_rounded,
              selected: typeClient == 'standard',
              onTap: () => onTypeChanged('standard'),
            ),
            const SizedBox(width: 10),
            TypeChip(
              label: 'Professionnel',
              icon: Icons.business_center_rounded,
              selected: typeClient == 'professionnel',
              onTap: () => onTypeChanged('professionnel'),
            ),
          ],
        ),
        if (typeClient == 'professionnel') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFF6B00).withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFFF6B00), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Accès aux forfaits pro et facturation mensuelle B2B.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFFF6B00)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),

        PrimaryButton(
          label: 'Créer mon compte',
          icon: Icons.check_circle_outline_rounded,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
