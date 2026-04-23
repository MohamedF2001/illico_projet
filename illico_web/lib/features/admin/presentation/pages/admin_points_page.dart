import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../point_illico/data/datasources/point_illico_remote_datasource.dart';
import '../../../point_illico/presentation/providers/point_illico_provider.dart';

/// Page admin des Points ILLICO.
/// API utilisée:
///  - GET /points → liste (verifyAdmin)
///  - POST /auth/point/register → { nom, telephone, motDePasse, adresse }
///  - PUT /points/:id/activation → { actif: bool }
class AdminPointsPage extends ConsumerWidget {
  const AdminPointsPage({super.key});

  void _showAddPointForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddPointDialog(onAdded: () {
        ref.read(pointIllicoListProvider.notifier).load();
      }),
    );
  }

  void _toggleActivation(
      BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = PointIllicoRemoteDataSource(apiClient);
    final r = await ds.toggleActivation(id, val);
    r.fold(
          (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.displayMessage))),
          (_) {
        ref.read(pointIllicoListProvider.notifier).load();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(val
              ? 'Point ILLICO activé ✅'
              : 'Point ILLICO désactivé'),
          backgroundColor: val ? AppColors.accent : AppColors.warning,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pointIllicoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Points ILLICO'),
            Text(
              '${state.items.length} point(s)',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            onPressed: () =>
                ref.read(pointIllicoListProvider.notifier).load(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPointForm(context, ref),
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label:
              const Text('Nouveau', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 36),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
        failure: state.error!,
        onRetry: () =>
            ref.read(pointIllicoListProvider.notifier).load(),
      )
          : state.items.isEmpty
          ? const EmptyState(
        title: 'Aucun point ILLICO',
        subtitle:
        'Créez des points de collecte pour votre réseau.',
        icon: Icons.store_outlined,
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, _) =>
        const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final point = state.items[i];
          final actif = point['actif'] as bool? ?? false;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (actif
                              ? AppColors.accent
                              : AppColors.textSecondary)
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.store_outlined,
                            color: actif
                                ? AppColors.accent
                                : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    point['nom'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                                // Badge actif
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 8,
                                      vertical: 3),
                                  decoration: BoxDecoration(
                                    color: actif
                                        ? AppColors.accent
                                        .withOpacity(0.1)
                                        : AppColors.danger
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(
                                        20),
                                  ),
                                  child: Text(
                                    actif ? 'ACTIF' : 'INACTIF',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w700,
                                        color: actif
                                            ? AppColors.accent
                                            : AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              point['telephone'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                  AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: actif,
                        onChanged: (val) =>
                            _toggleActivation(
                                context,
                                ref,
                                point['_id'] as String,
                                val),
                        activeThumbColor: AppColors.accent,
                      ),
                    ],
                  ),
                  if (point['adresse'] != null &&
                      (point['adresse'] as String)
                          .isNotEmpty) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            point['adresse'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color:
                                AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((point['commissionTotal'] as num? ??
                            0) >
                            0)
                          Text(
                            'Commission: ${(point['commissionTotal'] as num).toInt()} FCFA',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  DIALOG CRÉATION POINT ILLICO
//  Champs conformes à l'API:
//  POST /auth/point/register → { nom, telephone, motDePasse, adresse }
//  Le compte est créé avec actif=false (en attente activation)
// ════════════════════════════════════════════════════════════
class _AddPointDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddPointDialog({required this.onAdded});

  @override
  State<_AddPointDialog> createState() => _AddPointDialogState();
}

class _AddPointDialogState extends State<_AddPointDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ds = AuthRemoteDataSource(apiClient);
      // POST /auth/point/register → { nom, telephone, motDePasse, adresse }
      final result = await ds.registerPoint({
        'nom': _nomCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'motDePasse': _passCtrl.text,
        'adresse': _adresseCtrl.text.trim(),
      });

      result.fold(
            (failure) => setState(() {
          _isLoading = false;
          _error = failure.displayMessage;
        }),
            (point) {
          Navigator.pop(context);
          widget.onAdded();
          // Informer que le compte est en attente d'activation
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Point ILLICO créé. En attente d\'activation (actif=false). Activez-le depuis la liste.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 4),
          ));
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur inattendue.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store_outlined,
                          color: Color(0xFF7C3AED), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nouveau Point ILLICO',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          Text(
                            'Compte créé inactif — activation requise',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Nom ─────────────────────────────────────
                _Label('Nom du point *'),
                TextFormField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDeco(
                      hint: 'ex: Point ILLICO Haie Vive',
                      icon: Icons.store_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nom requis'
                      : null,
                ),
                const SizedBox(height: 14),

                // ── Téléphone ────────────────────────────────
                _Label('Numéro de téléphone *'),
                TextFormField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDeco(
                      hint: '+229 97 12 34 56',
                      icon: Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Téléphone requis';
                    }
                    if (!RegExp(r'^\+?[0-9\s\-()]{8,15}$')
                        .hasMatch(v.trim())) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Adresse ──────────────────────────────────
                _Label('Adresse *'),
                TextFormField(
                  controller: _adresseCtrl,
                  decoration: _inputDeco(
                      hint: 'ex: Cotonou, Haie Vive, Carrefour',
                      icon: Icons.location_on_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Adresse requise'
                      : null,
                ),
                const SizedBox(height: 14),

                // ── Mot de passe ─────────────────────────────
                _Label('Mot de passe (min. 6 caractères) *'),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _inputDeco(
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),

                // ── Info ─────────────────────────────────────
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.info, size: 14),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Le point sera créé avec actif=false. Vous devrez l\'activer manuellement via le bouton switch.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Erreur ───────────────────────────────────
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Actions ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LoadingButton(
                        onPressed: _submit,
                        label: 'Créer le point',
                        isLoading: _isLoading,
                        icon: Icons.store_mall_directory_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _Label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
  );

  InputDecoration _inputDeco(
      {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );
}