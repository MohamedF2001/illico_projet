import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../tarif/data/datasources/tarif_remote_datasource.dart';
import '../../../tarif/presentation/providers/tarif_provider.dart';

class AdminTarifsPage extends ConsumerWidget {
  const AdminTarifsPage({super.key});

  void _deleteTarif(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver ce tarif ?'),
        content: const Text(
            'Le tarif sera désactivé (soft delete). Il ne sera plus utilisé pour les nouvelles livraisons.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Désactiver',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(tarifListProvider.notifier).delete(id);
    }
  }

  void _showAddTarifForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddTarifDialog(onAdded: () {
        ref.read(tarifListProvider.notifier).load();
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tarifListProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tarifs'),
            Text(
              '${state.items.length} tarif(s) actif(s)',
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
            tooltip: 'Actualiser',
            onPressed: () => ref.read(tarifListProvider.notifier).load(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTarifForm(context, ref),
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
        onRetry: () => ref.read(tarifListProvider.notifier).load(),
      )
          : state.items.isEmpty
          ? const EmptyState(
        title: 'Aucun tarif configuré',
        subtitle:
        'Créez un tarif par combinaison véhicule + zone.',
        icon: Icons.price_change_outlined,
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, _) =>
        const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final tarif = state.items[i];
          final actif = tarif['actif'] as bool? ?? true;

          // Extraction véhicule et zone (peut être Map ou String)
          final vehiculeObj = tarif['vehicule'];
          final zoneObj = tarif['zone'];
          final vehiculeLabel = vehiculeObj is Map
              ? Formatters.vehiculeLabel(
              vehiculeObj['type'] as String? ?? '-')
              : '-';
          final zoneLabel = zoneObj is Map
              ? (zoneObj['nom'] as String? ?? '-')
              : '-';
          final supplement = zoneObj is Map
              ? (zoneObj['supplement'] as num?)?.toDouble() ?? 0
              : 0.0;

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
                          color: actif
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.textSecondary
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.price_change_outlined,
                            color: actif
                                ? AppColors.primary
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
                                Text(
                                  vehiculeLabel,
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward,
                                    size: 14,
                                    color:
                                    AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(zoneLabel,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.info,
                                        fontWeight:
                                        FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Base: ${Formatters.currency((tarif['prixBase'] as num?)?.toDouble() ?? 0)}'
                                  ' · ${Formatters.currency((tarif['coutKm'] as num?)?.toDouble() ?? 0)}/km',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                  AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Badge actif/inactif
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: actif
                              ? AppColors.accent.withOpacity(0.1)
                              : AppColors.danger
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          actif ? 'ACTIF' : 'INACTIF',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: actif
                                  ? AppColors.accent
                                  : AppColors.danger),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        tooltip: 'Désactiver',
                        onPressed: actif
                            ? () => _deleteTarif(
                            context, ref, tarif['_id'])
                            : null,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Grille des suppléments
                  Row(
                    children: [
                      _TarifInfo(
                        label: 'Urgence',
                        value: Formatters.currency(
                            (tarif['supplementUrgent'] as num?)
                                ?.toDouble() ??
                                0),
                        icon: Icons.flash_on,
                        color: AppColors.warning,
                      ),
                      _TarifInfo(
                        label: 'Nuit',
                        value: Formatters.currency(
                            (tarif['supplementNuit'] as num?)
                                ?.toDouble() ??
                                0),
                        icon: Icons.nights_stay,
                        color: AppColors.info,
                      ),
                      _TarifInfo(
                        label: 'Poids/kg',
                        value: Formatters.currency(
                            (tarif['supplementPoids'] as num?)
                                ?.toDouble() ??
                                0),
                        icon: Icons.scale,
                        color: AppColors.primary,
                      ),
                      _TarifInfo(
                        label: 'Remise Pt.',
                        value:
                        '${tarif['remisePointIllico'] ?? 0}%',
                        icon: Icons.store_outlined,
                        color: AppColors.accent,
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

// ── Widget info colonne ─────────────────────────────────────
class _TarifInfo extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _TarifInfo(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textSecondary)),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  DIALOG CRÉATION TARIF
//  Champs conformes à l'API:
//  POST /api/tarifs → { vehicule, zone, prixBase, coutKm,
//                       supplementUrgent, supplementNuit,
//                       supplementPoids, remisePointIllico }
// ════════════════════════════════════════════════════════════
class _AddTarifDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddTarifDialog({required this.onAdded});

  @override
  State<_AddTarifDialog> createState() => _AddTarifDialogState();
}

class _AddTarifDialogState extends State<_AddTarifDialog> {
  // Contrôleurs de champs numériques
  final _prixBaseCtrl = TextEditingController();
  final _coutKmCtrl = TextEditingController();
  final _supplementUrgentCtrl = TextEditingController(text: '0');
  final _supplementNuitCtrl = TextEditingController(text: '0');
  final _supplementPoidsCtrl = TextEditingController(text: '0');
  final _remisePointCtrl = TextEditingController(text: '0');

  // Listes pour les dropdowns
  List<Map<String, dynamic>> _vehicules = [];
  List<Map<String, dynamic>> _zones = [];

  // Sélections
  String? _vehiculeId;
  String? _zoneId;

  bool _isLoading = false;
  bool _loadingData = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _prixBaseCtrl.dispose();
    _coutKmCtrl.dispose();
    _supplementUrgentCtrl.dispose();
    _supplementNuitCtrl.dispose();
    _supplementPoidsCtrl.dispose();
    _remisePointCtrl.dispose();
    super.dispose();
  }

  /// Charge les véhicules et zones en parallèle
  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        apiClient.dio.get('/vehicules', queryParameters: {'actif': true}),
        apiClient.dio.get('/zones', queryParameters: {'actif': true}),
      ]);

      final vehiculesList =
          (results[0].data['data'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
      final zonesList =
          (results[1].data['data'] as List?)?.cast<Map<String, dynamic>>() ??
              [];

      setState(() {
        _vehicules = vehiculesList;
        _zones = zonesList;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les véhicules et zones.';
        _loadingData = false;
      });
    }
  }

  Future<void> _submit() async {
    // Validations
    if (_vehiculeId == null) {
      setState(() => _error = 'Sélectionnez un véhicule.');
      return;
    }
    if (_zoneId == null) {
      setState(() => _error = 'Sélectionnez une zone.');
      return;
    }
    final prixBase = double.tryParse(_prixBaseCtrl.text);
    final coutKm = double.tryParse(_coutKmCtrl.text);
    if (prixBase == null || prixBase < 0) {
      setState(() => _error = 'Prix de base invalide.');
      return;
    }
    if (coutKm == null || coutKm < 0) {
      setState(() => _error = 'Coût par km invalide.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ds = TarifRemoteDataSource(apiClient);
      final result = await ds.create({
        'vehicule': _vehiculeId,
        'zone': _zoneId,
        'prixBase': prixBase,
        'coutKm': coutKm,
        'supplementUrgent':
        double.tryParse(_supplementUrgentCtrl.text) ?? 0,
        'supplementNuit': double.tryParse(_supplementNuitCtrl.text) ?? 0,
        'supplementPoids':
        double.tryParse(_supplementPoidsCtrl.text) ?? 0,
        'remisePointIllico':
        double.tryParse(_remisePointCtrl.text) ?? 0,
      });

      result.fold(
            (failure) =>
            setState(() {
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    child: const Icon(Icons.price_change_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Nouveau tarif',
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

              if (_loadingData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Chargement des véhicules et zones...',
                            style:
                            TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else ...[
                // ── Sélection véhicule ──────────────────────
                _Label('Véhicule *'),
                DropdownButtonFormField<String>(
                  initialValue: _vehiculeId,
                  decoration: _inputDeco(
                      hint: 'Sélectionnez un véhicule',
                      icon: Icons.two_wheeler),
                  items: _vehicules.map((v) {
                    final type =
                    Formatters.vehiculeLabel(v['type'] as String? ?? '');
                    final tarif = Formatters.currency(
                        (v['tarifBase'] as num?)?.toDouble() ?? 0);
                    return DropdownMenuItem<String>(
                      value: v['_id'] as String,
                      child: Text('$type — Base: $tarif'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _vehiculeId = val),
                ),
                const SizedBox(height: 14),

                // ── Sélection zone ──────────────────────────
                _Label('Zone *'),
                DropdownButtonFormField<String>(
                  initialValue: _zoneId,
                  decoration: _inputDeco(
                      hint: 'Sélectionnez une zone', icon: Icons.map_outlined),
                  items: _zones.map((z) {
                    final nom = z['nom'] as String? ?? '';
                    final supp = Formatters.currency(
                        (z['supplement'] as num?)?.toDouble() ?? 0);
                    return DropdownMenuItem<String>(
                      value: z['_id'] as String,
                      child: Text('$nom (+$supp suppl.)'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _zoneId = val),
                ),
                const SizedBox(height: 20),

                const Divider(),
                const SizedBox(height: 12),
                const Text('Tarification de base',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 10),

                // ── Prix base + coût km ─────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Prix de base (FCFA) *'),
                          TextFormField(
                            controller: _prixBaseCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: 'ex: 500',
                                icon: Icons.attach_money),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Coût par km (FCFA) *'),
                          TextFormField(
                            controller: _coutKmCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: 'ex: 150', icon: Icons.route),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Divider(),
                const SizedBox(height: 12),
                const Text('Suppléments',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 10),

                // ── Suppléments sur 2 colonnes ──────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Urgence (FCFA)'),
                          TextFormField(
                            controller: _supplementUrgentCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: '0', icon: Icons.flash_on),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Nuit (FCFA)'),
                          TextFormField(
                            controller: _supplementNuitCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: '0', icon: Icons.nights_stay),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Poids /kg suppl. (FCFA)'),
                          TextFormField(
                            controller: _supplementPoidsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: '0', icon: Icons.scale),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Remise Point ILLICO (%)'),
                          TextFormField(
                            controller: _remisePointCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                                hint: '0 – 100', icon: Icons.store_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // ── Erreur ─────────────────────────────────────
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

              // ── Actions ─────────────────────────────────────
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
                      onPressed: _loadingData ? null : _submit,
                      label: 'Créer le tarif',
                      isLoading: _isLoading,
                      icon: Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),
            ],
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

  InputDecoration _inputDeco({required String hint, required IconData icon}) =>
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );
}