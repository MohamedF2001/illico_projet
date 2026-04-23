import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/vehicule_provider.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/vehicule_remote_datasource.dart';
import '../../data/repositories/vehicule_repository_impl.dart';

class AdminVehiculesPage extends ConsumerWidget {
  const AdminVehiculesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiculeListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(vehiculeListProvider.notifier).load(),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => _showVehiculeForm(context, ref),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(vehiculeListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun véhicule',
              icon: Icons.directions_car_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _VehiculeCard(
                vehicule: state.items[i],
                onRefresh: () => ref.read(vehiculeListProvider.notifier).load(),
              ),
            ),
    );
  }

  void _showVehiculeForm(
    BuildContext context,
    WidgetRef ref, [
    VehiculeEntity? v,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VehiculeFormSheet(
        vehicule: v,
        onSaved: () => ref.read(vehiculeListProvider.notifier).load(),
      ),
    );
  }

  void _deleteVehicule(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce véhicule ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(vehiculeListProvider.notifier).delete(id);
    }
  }
}

class _VehiculeCard extends ConsumerWidget {
  final VehiculeEntity vehicule;
  final VoidCallback onRefresh;
  const _VehiculeCard({required this.vehicule, required this.onRefresh});

  void _toggleActivation(BuildContext context, WidgetRef ref, bool val) async {
    final ds = VehiculeRemoteDataSource(apiClient);
    final r = await ds.update(vehicule.id!, {'actif': val});
    r.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.displayMessage))),
      (_) => onRefresh(),
    );
  }

  void _deleteVehicule(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce véhicule ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(vehiculeListProvider.notifier).delete(vehicule.id!);
    }
  }

  IconData get _icon => switch (vehicule.type) {
    'velo' => Icons.pedal_bike,
    'moto' => Icons.two_wheeler,
    'voiture' => Icons.directions_car,
    'camionnette' => Icons.local_shipping,
    _ => Icons.trip_origin,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.vehiculeLabel(vehicule.type),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Base: ${Formatters.currency(vehicule.tarifBase)} · ${Formatters.currency(vehicule.coutParKm)}/km',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Commission: ${vehicule.commission.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.info,
                size: 20,
              ),
              tooltip: 'Modifier',
              onPressed: () {
                final parent = context
                    .findAncestorWidgetOfExactType<AdminVehiculesPage>();
                if (parent != null) {
                  parent._showVehiculeForm(context, ref, vehicule);
                }
              },
            ),
            Switch(
              value: vehicule.actif,
              onChanged: (val) => _toggleActivation(context, ref, val),
              activeThumbColor: AppColors.accent,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
                size: 20,
              ),
              tooltip: 'Supprimer',
              onPressed: () {
                final parent = context
                    .findAncestorWidgetOfExactType<AdminVehiculesPage>();
                if (parent != null) {
                  parent._deleteVehicule(context, ref, vehicule.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiculeFormSheet extends StatefulWidget {
  final VehiculeEntity? vehicule;
  final VoidCallback onSaved;
  const _VehiculeFormSheet({this.vehicule, required this.onSaved});

  @override
  State<_VehiculeFormSheet> createState() => _VehiculeFormSheetState();
}

class _VehiculeFormSheetState extends State<_VehiculeFormSheet> {
  final _typeCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _commCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late bool _actif;
  bool _isLoading = false;
  String? _error;
  final _repo = VehiculeRepositoryImpl(VehiculeRemoteDataSource(apiClient));

  @override
  void initState() {
    super.initState();
    if (widget.vehicule != null) {
      _typeCtrl.text = widget.vehicule!.type;
      _baseCtrl.text = widget.vehicule!.tarifBase.toString();
      _kmCtrl.text = widget.vehicule!.coutParKm.toString();
      _commCtrl.text = widget.vehicule!.commission.toString();
      _descCtrl.text = widget.vehicule!.description ?? '';
    }
    _actif = widget.vehicule?.actif ?? true;
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _baseCtrl.dispose();
    _kmCtrl.dispose();
    _commCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    demoGuard(context, () async {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final body = {
        'type': _typeCtrl.text.trim(),
        'tarifBase': double.tryParse(_baseCtrl.text) ?? 0,
        'coutParKm': double.tryParse(_kmCtrl.text) ?? 0,
        'commission': double.tryParse(_commCtrl.text) ?? 0,
        'description': _descCtrl.text.trim(),
        if (widget.vehicule != null) 'actif': _actif,
      };
      final r = widget.vehicule != null
          ? await _repo.update(widget.vehicule!.id!, body)
          : await _repo.create(body);
      r.fold(
        (f) => setState(() {
          _isLoading = false;
          _error = f.displayMessage;
        }),
        (_) {
          Navigator.pop(context);
          widget.onSaved();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.vehicule == null
                ? 'Ajouter un véhicule'
                : 'Modifier le véhicule',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _typeCtrl.text.isEmpty ? null : _typeCtrl.text,
            decoration: const InputDecoration(labelText: 'Type de véhicule'),
            items: ['velo', 'moto', 'tricycle', 'voiture', 'camionnette']
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(Formatters.vehiculeLabel(t)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _typeCtrl.text = v ?? ''),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _baseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tarif base (FCFA)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _kmCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coût/km',
                    prefixIcon: Icon(Icons.route),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Commission (%)',
              prefixIcon: Icon(Icons.percent),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
            ),
          ),
          if (widget.vehicule != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: Text('Véhicule actif',
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          const SizedBox(height: 20),
          LoadingButton(
            onPressed: _save,
            label: widget.vehicule == null ? 'Ajouter' : 'Enregistrer',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
