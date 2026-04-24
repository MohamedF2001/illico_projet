import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../forfait/data/datasources/forfait_remote_datasource.dart';
import '../../../forfait/presentation/providers/forfait_provider.dart';

class AdminForfaitsPage extends ConsumerWidget {
  const AdminForfaitsPage({super.key});

  void _deleteForfait(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver ce forfait ?'),
        content: const Text(
            'Le forfait ne sera plus proposé aux nouveaux clients. Les souscriptions en cours ne sont pas affectées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child:
            const Text('Désactiver', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(forfaitListProvider.notifier).delete(id);
    }
  }

  void _showAddForfaitForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ForfaitDialog(onSaved: () {
        ref.read(forfaitListProvider.notifier).load();
      }),
    );
  }

  void _showEditForfaitForm(
      BuildContext context, WidgetRef ref, Map<String, dynamic> forfait) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ForfaitDialog(
        forfait: forfait,
        onSaved: () {
          ref.read(forfaitListProvider.notifier).load();
        },
      ),
    );
  }

  void _toggleActivation(
      BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = ForfaitRemoteDataSource(apiClient);
    final r = await ds.update(id, {'actif': val});
    r.fold(
          (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.displayMessage))),
          (_) => ref.read(forfaitListProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forfaitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Forfaits'),
            Text(
              '${state.items.length} forfait(s)',
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
            onPressed: () => ref.read(forfaitListProvider.notifier).load(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddForfaitForm(context, ref),
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
            ref.read(forfaitListProvider.notifier).load(),
      )
          : state.items.isEmpty
          ? const EmptyState(
        title: 'Aucun forfait',
        subtitle:
        'Créez des forfaits pour les clients professionnels.',
        icon: Icons.card_membership_outlined,
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, _) =>
        const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final forfait = state.items[i];
          final actif = forfait['actif'] as bool? ?? false;
          final remise =
              (forfait['remise'] as num?)?.toInt() ?? 0;
          final livraisonsIncluses =
              (forfait['livraisonsIncluses'] as num?)?.toInt() ??
                  0;
          final dureeJours =
              (forfait['dureeJours'] as num?)?.toInt() ?? 0;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Badge remise
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text('$remise%',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                            const Text('remise',
                                style: TextStyle(
                                    fontSize: 8,
                                    color:
                                    AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              forfait['nom'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              forfait['description'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                  AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(
                                (forfait['prix'] as num?)
                                    ?.toDouble() ??
                                    0),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primary),
                          ),
                          Text(
                            '$dureeJours jours',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Bouton éditer
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.info, size: 20),
                        tooltip: 'Modifier',
                        onPressed: () =>
                            _showEditForfaitForm(context, ref, forfait),
                      ),
                      Switch(
                        value: actif,
                        onChanged: (val) => _toggleActivation(
                            context, ref, forfait['_id'], val),
                        activeThumbColor: AppColors.accent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        tooltip: 'Désactiver',
                        onPressed: () => _deleteForfait(
                            context, ref, forfait['_id']),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      _ForfaitStat(
                        icon: Icons.local_shipping_outlined,
                        label: 'Livraisons incluses',
                        value: '$livraisonsIncluses',
                        color: AppColors.info,
                      ),
                      _ForfaitStat(
                        icon: Icons.calendar_today_outlined,
                        label: 'Durée',
                        value: '$dureeJours j',
                        color: AppColors.warning,
                      ),
                      _ForfaitStat(
                        icon: Icons.discount_outlined,
                        label: 'Réduction',
                        value: '$remise%',
                        color: AppColors.accent,
                      ),
                      _ForfaitStat(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: actif ? 'Actif' : 'Inactif',
                        color: actif
                            ? AppColors.accent
                            : AppColors.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ForfaitStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _ForfaitStat(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  DIALOG CRÉATION / ÉDITION FORFAIT
//  Champs conformes à l'API:
//  POST /api/forfaits → { nom, description, prix,
//                         dureeJours, livraisonsIncluses, remise }
//  PUT /api/forfaits/:id → mêmes champs + actif
// ════════════════════════════════════════════════════════════
class _ForfaitDialog extends StatefulWidget {
  final Map<String, dynamic>? forfait; // null = création
  final VoidCallback onSaved;
  const _ForfaitDialog({this.forfait, required this.onSaved});

  @override
  State<_ForfaitDialog> createState() => _ForfaitDialogState();
}

class _ForfaitDialogState extends State<_ForfaitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _dureeJoursCtrl;
  late final TextEditingController _livraisonsCtrl;
  late final TextEditingController _remiseCtrl;
  late bool _actif;

  bool _isLoading = false;
  String? _error;

  bool get _isEditing => widget.forfait != null;

  @override
  void initState() {
    super.initState();
    final f = widget.forfait;
    _nomCtrl = TextEditingController(text: f?['nom'] ?? '');
    _descCtrl = TextEditingController(text: f?['description'] ?? '');
    _prixCtrl = TextEditingController(text: f?['prix']?.toString() ?? '');
    _dureeJoursCtrl = TextEditingController(text: f?['dureeJours']?.toString() ?? '');
    _livraisonsCtrl = TextEditingController(text: f?['livraisonsIncluses']?.toString() ?? '');
    _remiseCtrl = TextEditingController(text: f?['remise']?.toString() ?? '0');
    _actif = f?['actif'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _prixCtrl.dispose();
    _dureeJoursCtrl.dispose();
    _livraisonsCtrl.dispose();
    _remiseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ds = ForfaitRemoteDataSource(apiClient);
      final body = {
        'nom': _nomCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'prix': double.tryParse(_prixCtrl.text) ?? 0,
        'dureeJours': int.tryParse(_dureeJoursCtrl.text) ?? 0,
        'livraisonsIncluses': int.tryParse(_livraisonsCtrl.text) ?? 0,
        'remise': double.tryParse(_remiseCtrl.text) ?? 0,
        if (_isEditing) 'actif': _actif,
      };

      final result = _isEditing
          ? await ds.update(widget.forfait!['_id'] as String, body)
          : await ds.create(body);

      result.fold(
            (failure) => setState(() {
          _isLoading = false;
          _error = failure.displayMessage;
        }),
            (_) {
          Navigator.pop(context);
          widget.onSaved();
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                          _isEditing ? Icons.edit_outlined : Icons.card_membership_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(_isEditing ? 'Modifier le forfait' : 'Nouveau forfait',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Nom ─────────────────────────────────────
                _Label('Nom du forfait *'),
                TextFormField(
                  controller: _nomCtrl,
                  decoration: _inputDeco(
                      hint: 'ex: Pro Monthly', icon: Icons.badge_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nom requis'
                      : null,
                ),
                const SizedBox(height: 14),

                // ── Description ──────────────────────────────
                _Label('Description (optionnel)'),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: _inputDeco(
                      hint: 'ex: 50 livraisons/mois avec 15% de remise',
                      icon: Icons.notes_outlined),
                ),
                const SizedBox(height: 14),

                // ── Prix ─────────────────────────────────────
                _Label('Prix (FCFA) *'),
                TextFormField(
                  controller: _prixCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco(
                      hint: 'ex: 25000', icon: Icons.attach_money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Prix requis';
                    if (double.tryParse(v) == null) return 'Nombre invalide';
                    if (double.parse(v) < 0) return 'Doit être positif';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Durée + Livraisons incluses ──────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Durée (jours) *'),
                          TextFormField(
                            controller: _dureeJoursCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: 'ex: 30',
                                icon: Icons.calendar_today_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requis';
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return '≥ 1 jour';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Livraisons incluses *'),
                          TextFormField(
                            controller: _livraisonsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: 'ex: 50',
                                icon: Icons.local_shipping_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requis';
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return '≥ 1';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Remise ───────────────────────────────────
                _Label('Remise sur les livraisons (%) *'),
                TextFormField(
                  controller: _remiseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco(
                      hint: '0 – 100 %', icon: Icons.discount_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    final n = double.tryParse(v);
                    if (n == null) return 'Nombre invalide';
                    if (n < 0 || n > 100) return '0 à 100%';
                    return null;
                  },
                ),

                // ── Toggle actif (édition uniquement) ──────────
                if (_isEditing) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.toggle_on_outlined,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Forfait actif',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textPrimary)),
                        ),
                        Switch(
                          value: _actif,
                          onChanged: (v) => setState(() => _actif = v),
                          activeThumbColor: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ],

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
                                  color: AppColors.danger, fontSize: 13)),
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
                        onPressed:
                        _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LoadingButton(
                        onPressed: _submit,
                        label: _isEditing ? 'Enregistrer' : 'Créer le forfait',
                        isLoading: _isLoading,
                        icon: _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
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