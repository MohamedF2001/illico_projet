import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

class ClientRegisterPage extends ConsumerStatefulWidget {
  const ClientRegisterPage({super.key});
  @override ConsumerState<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends ConsumerState<ClientRegisterPage> {
  final _phoneCtrl   = TextEditingController();
  final _nomCtrl     = TextEditingController();
  final _pinCtrl     = TextEditingController();
  final _adresseCtrl = TextEditingController();
  String _step = 'phone'; // 'phone' | 'otp' | 'form'
  String _otp = '';
  bool _isLoading = false;
  String? _error;
  final _repo = AuthRepositoryImpl(AuthRemoteDataSource(apiClient));

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    setState(() { _isLoading = true; _error = null; });
    final r = await _repo.initClientRegister(telephone: _phoneCtrl.text.trim());
    r.fold(
      (f) => setState(() { _isLoading = false; _error = f.displayMessage; }),
      (_) => setState(() { _isLoading = false; _step = 'otp'; }),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) { setState(() => _error = 'Entrez les 6 chiffres.'); return; }
    setState(() => _step = 'form');
  }

  Future<void> _register() async {
    if (_nomCtrl.text.trim().isEmpty || _pinCtrl.text.isEmpty) { setState(() => _error = 'Tous les champs sont requis.'); return; }
    setState(() { _isLoading = true; _error = null; });
    final r = await _repo.registerClient(body: {
      'telephone': _phoneCtrl.text.trim(),
      'nom': _nomCtrl.text.trim(),
      'codePin': _pinCtrl.text,
      'otp': _otp,
      'adresse': _adresseCtrl.text.trim(),
      'typeClient': 'standard',
    });
    r.fold(
      (f) => setState(() { _isLoading = false; _error = f.displayMessage; }),
      (_) { setState(() => _isLoading = false); context.go('/auth/login'); },
    );
  }

  @override void dispose() { _phoneCtrl.dispose(); _nomCtrl.dispose(); _pinCtrl.dispose(); _adresseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte'), leading: BackButton(onPressed: () => context.go('/auth/login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Step indicator
            Row(children: ['Téléphone', 'OTP', 'Informations'].asMap().entries.map((e) {
              final active = (['phone', 'otp', 'form'].indexOf(_step)) >= e.key;
              return Expanded(child: Row(children: [
                Container(width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: active ? AppColors.primary : AppColors.divider),
                  child: Center(child: Text('${e.key + 1}',
                    style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)))),
                if (e.key < 2) Expanded(child: Container(height: 2,
                  color: active ? AppColors.primary : AppColors.divider)),
              ]));
            }).toList()),
            const SizedBox(height: 32),
            if (_step == 'phone') ...[
              const Text('Votre numéro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Un code de vérification vous sera envoyé par SMS', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined), hintText: '+229 97 12 34 56')),
              const SizedBox(height: 24),
              LoadingButton(onPressed: _sendOtp, label: 'Envoyer le code', isLoading: _isLoading),
            ] else if (_step == 'otp') ...[
              const Text('Code OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Entrez le code envoyé au ${_phoneCtrl.text}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              TextFormField(keyboardType: TextInputType.number, maxLength: 6,
                onChanged: (v) => setState(() => _otp = v),
                decoration: const InputDecoration(labelText: 'Code à 6 chiffres', prefixIcon: Icon(Icons.pin_outlined)),
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              LoadingButton(onPressed: _verifyOtp, label: 'Vérifier', isLoading: _isLoading),
              Center(child: TextButton(onPressed: _sendOtp, child: const Text('Renvoyer le code'))),
            ] else ...[
              const Text('Vos informations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              TextFormField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 14),
              TextFormField(controller: _pinCtrl, keyboardType: TextInputType.number, maxLength: 6, obscureText: true,
                decoration: const InputDecoration(labelText: 'Code PIN (4-6 chiffres)', prefixIcon: Icon(Icons.pin_outlined), counterText: '')),
              const SizedBox(height: 14),
              TextFormField(controller: _adresseCtrl, decoration: const InputDecoration(labelText: 'Adresse (optionnel)', prefixIcon: Icon(Icons.location_on_outlined))),
              const SizedBox(height: 24),
              LoadingButton(onPressed: _register, label: 'Créer mon compte', isLoading: _isLoading),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
            ],
          ]),
        ),
      ),
    );
  }
}
