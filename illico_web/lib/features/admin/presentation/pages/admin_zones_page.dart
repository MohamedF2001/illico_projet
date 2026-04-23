import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../zone/data/datasources/zone_remote_datasource.dart';
import '../../../zone/presentation/providers/zone_provider.dart';

class AdminZonesPage extends ConsumerWidget {
  const AdminZonesPage({super.key});

  void _deleteZone(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver cette zone ?'),
        content: const Text(
            'La zone sera désactivée. Elle ne peut pas être supprimée si des tarifs actifs l\'utilisent.'),
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
      ref.read(zoneListProvider.notifier).delete(id);
    }
  }

  void _showAddZoneForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddZoneDialog(onAdded: () {
        ref.read(zoneListProvider.notifier).load();
      }),
    );
  }

  void _toggleActivation(
      BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = ZoneRemoteDataSource(apiClient);
    final r = await ds.update(id, {'actif': val});
    r.fold(
          (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.displayMessage))),
          (_) => ref.read(zoneListProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(zoneListProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Zones de livraison'),
            Text(
              '${state.items.length} zone(s)',
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
            onPressed: () => ref.read(zoneListProvider.notifier).load(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddZoneForm(context, ref),
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label:
              const Text('Nouvelle', style: TextStyle(color: Colors.white)),
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
        onRetry: () => ref.read(zoneListProvider.notifier).load(),
      )
          : state.items.isEmpty
          ? const EmptyState(
        title: 'Aucune zone',
        subtitle:
        'Créez des zones géographiques pour configurer les tarifs.',
        icon: Icons.map_outlined,
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, _) =>
        const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final zone = state.items[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.info
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map_outlined,
                            color: AppColors.info),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.nom,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            if (zone.description != null &&
                                zone.description!.isNotEmpty)
                              Text(
                                zone.description!,
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
                      // Supplément badge
                      if (zone.supplement > 0)
                        Container(
                          margin:
                          const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.warning
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            '+${Formatters.currency(zone.supplement)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      Switch(
                        value: zone.actif,
                        onChanged: (val) => _toggleActivation(
                            context, ref, zone.id!, val),
                        activeThumbColor: AppColors.accent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        onPressed: () => _deleteZone(
                            context, ref, zone.id!),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      _Info(
                          label: 'Supplément',
                          value: Formatters.currency(
                              zone.supplement)),
                      _Info(
                        label: 'Statut',
                        value: zone.actif ? 'ACTIVE' : 'INACTIVE',
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

// ════════════════════════════════════════════════════════════
//  DIALOG CRÉATION ZONE
//  Champs conformes à l'API:
//  POST /api/zones → { nom, description, supplement }
// ════════════════════════════════════════════════════════════
class _AddZoneDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddZoneDialog({required this.onAdded});

  @override
  State<_AddZoneDialog> createState() => _AddZoneDialogState();
}

class _AddZoneDialogState extends State<_AddZoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _suppCtrl = TextEditingController(text: '0');

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _suppCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ds = ZoneRemoteDataSource(apiClient);
      final result = await ds.create({
        'nom': _nomCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'supplement': double.tryParse(_suppCtrl.text) ?? 0,
      });

      result.fold(
            (failure) => setState(() {
          _isLoading = false;
          _error = failure.displayMessage;
        }),
            (_) {
          Navigator.pop(context);
          widget.onAdded();
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
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
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.map_outlined,
                          color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Nouvelle zone',
                        style: TextStyle(
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
                _Label('Nom de la zone *'),
                TextFormField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDeco(
                      hint: 'ex: Cotonou Centre', icon: Icons.location_on_outlined),
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
                      hint: 'ex: Zone urbaine dense', icon: Icons.notes_outlined),
                ),
                const SizedBox(height: 14),

                // ── Supplément ───────────────────────────────
                _Label('Supplément tarifaire (FCFA)'),
                TextFormField(
                  controller: _suppCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco(
                      hint: '0', icon: Icons.add_circle_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = double.tryParse(v);
                    if (n == null) return 'Nombre invalide';
                    if (n < 0) return 'Doit être ≥ 0';
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Montant ajouté automatiquement au tarif dans cette zone.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
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
                        label: 'Créer la zone',
                        isLoading: _isLoading,
                        icon: Icons.add_location_outlined,
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

class _Info extends StatelessWidget {
  final String label, value;
  const _Info({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
      Text(value,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600)),
    ],
  );
}