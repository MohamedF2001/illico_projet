import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../providers/auth_provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/loading_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _selectedRole = 'Client';
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .login(
          role: _selectedRole,
          email: _selectedRole == 'Admin' ? _emailCtrl.text.trim() : null,
          telephone: _selectedRole != 'Admin' ? _phoneCtrl.text.trim() : null,
          motDePasse: _selectedRole != 'Client' ? _passCtrl.text : null,
          codePin: _selectedRole == 'Client' ? _pinCtrl.text : null,
        );
    if (ok && mounted) context.go(_homeForRole(_selectedRole));
  }

  String _homeForRole(String r) => switch (r) {
    'Client' => '/home',
    'Livreur' => '/livreur/missions',
    'PointIllico' => '/point/colis',
    'Admin' => '/admin/dashboard',
    _ => '/auth/login',
  };

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ILLICO DELIVERY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          'Livré. Maintenant.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisissez votre profil pour continuer',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                // Role selector
                Row(
                  children: ['Client', 'Livreur', 'PointIllico', 'Admin']
                      .map(
                        (r) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              onTap: () => setState(() => _selectedRole = r),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedRole == r
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedRole == r
                                        ? AppColors.primary
                                        : AppColors.divider,
                                  ),
                                ),
                                child: Text(
                                  _roleLabel(r),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRole == r
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (_selectedRole == 'Admin')
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  )
                else
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '+229 97 12 34 56',
                    ),
                    validator: Validators.phone,
                  ),
                const SizedBox(height: 14),
                if (_selectedRole == 'Client')
                  TextFormField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: _obscure,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Code PIN (4-6 chiffres)',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: Validators.pin,
                  )
                else
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.error!.displayMessage,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Se connecter',
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 16),
                if (_selectedRole == 'Client')
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: const Text(
                        'Pas de compte ? Créer un compte',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel(String r) => switch (r) {
    'Client' => 'Client',
    'Livreur' => 'Livreur',
    'PointIllico' => 'Point',
    'Admin' => 'Admin',
    _ => r,
  };
}
