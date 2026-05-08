import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../livreur/presentation/providers/livreur_provider.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../domain/entities/livraison_entity.dart';

class LivraisonDetailPage extends ConsumerStatefulWidget {
  final String id;
  const LivraisonDetailPage({super.key, required this.id});
  @override
  ConsumerState<LivraisonDetailPage> createState() => _LivraisonDetailPageState();
}

class _LivraisonDetailPageState extends ConsumerState<LivraisonDetailPage> {
  LivraisonEntity? _livraison;
  bool _isLoading = true;
  String? _error;
  final _repo = LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });

    final r = await _repo.getById(widget.id);

    r.fold(
      (f) => setState(() { _isLoading = false; _error = f.displayMessage; }),
      (l) => setState(() { _isLoading = false; _livraison = l; }),
    );
  }

  Future<void> _submitRating() async {
    if (_userRating == 0) return;
    demoGuard(context, () async {
      final r = await _repo.rateLivreur(widget.id, _userRating);
      r.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(f.displayMessage), backgroundColor: AppColors.danger)),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Merci pour votre note !'),
              backgroundColor: Colors.green));
          _load();
        },
      );
    });
  }

  Future<void> _updateStatut(String newStatut) async {
    demoGuard(context, () async {
      setState(() => _isLoading = true);
      final r = await _repo.updateStatut(widget.id, newStatut);
      r.fold(
        (f) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(f.displayMessage), backgroundColor: AppColors.danger));
        },
        (_) => _load(),
      );
    });
  }

  Future<void> _accepterMission() async {
    demoGuard(context, () async {
      setState(() => _isLoading = true);
      final r = await _repo.accepter(widget.id);
      r.fold(
        (f) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(f.displayMessage), backgroundColor: AppColors.danger));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Livraison acceptée !'), backgroundColor: Colors.green));
          ref.read(missionsProvider.notifier).loadAll();
          _load();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
      );
    }

    final l = _livraison!;
    final isDone = l.statut == 'livré';
    final user = ref.read(authProvider).user;
    final isLivreur = user?.role == 'Livreur';

    return Scaffold(
      appBar: AppBar(title: Text('Suivi Livraison #${l.codeSuivi ?? l.id?.substring(l.id!.length - 6) ?? '-'}')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map View
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(l.pointDepart.coordinates[1], l.pointDepart.coordinates[0]),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.illico.delivery',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(l.pointDepart.coordinates[1], l.pointDepart.coordinates[0]),
                            child: const Icon(Icons.location_on, color: AppColors.accent, size: 30),
                          ),
                          Marker(
                            point: LatLng(l.pointArrivee.coordinates[1], l.pointArrivee.coordinates[0]),
                            child: const Icon(Icons.flag, color: AppColors.primary, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _SectionCard(
                title: 'Statut actuel',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatutBadge(statut: l.statut),
                        Text(Formatters.currency(l.prixFinal ?? l.prixEstime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (l.statut == 'en_attente') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Recherche d\'un livreur en cours...',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (l.codeSuivi != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Code de suivi unique', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l.codeSuivi!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.primary)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              // Action de copie (facultatif mais sympa)
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (isDone && l.noteLivreur == null) ...[
                _SectionCard(
                  title: 'Noter le livreur',
                  child: Column(
                    children: [
                      const Text('Comment s\'est passée votre livraison ?'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => IconButton(
                          icon: Icon(index < _userRating ? Icons.star : Icons.star_border, color: AppColors.warning, size: 32),
                          onPressed: () => setState(() => _userRating = index + 1.0),
                        )),
                      ),
                      const SizedBox(height: 12),
                      LoadingButton(onPressed: _userRating > 0 ? _submitRating : null, label: 'Envoyer la note'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _SectionCard(
                title: 'Trajet',
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.location_on,
                        color: AppColors.accent,
                        label: 'Départ',
                        value:
                            '${l.pointDepart.nomContact}\n${l.pointDepart.adresse}\nTél: ${l.pointDepart.telephoneContact}'),
                    const Divider(height: 24),
                    _InfoRow(
                        icon: Icons.flag_rounded,
                        color: AppColors.primary,
                        label: 'Arrivée',
                        value:
                            '${l.pointArrivee.nomContact}\n${l.pointArrivee.adresse}\nTél: ${l.pointArrivee.telephoneContact}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _SectionCard(
                title: 'Détails du colis',
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Nature',
                        value: l.natureColis ?? 'Non spécifié'),
                    const SizedBox(height: 8),
                    _InfoRow(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Poids',
                        value: '${l.poids} kg'),
                    const SizedBox(height: 8),
                    _InfoRow(
                        icon: Icons.speed,
                        label: 'Mode',
                        value: l.mode == 'express' ? 'Express' : 'Point ILLICO'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (l.livreur != null) ...[
                _SectionCard(
                  title: 'Livreur',
                  child: Row(
                    children: [
                      const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.livreur['nom'] ?? 'Livreur',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(l.livreur['telephone'] ?? '',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],


              // ── Actions Livreur ─────────────────────────
              if (isLivreur && l.statut != 'livré' && l.statut != 'annulé') ...[
                const SizedBox(height: 20),
                const Text('Actions Livreur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (l.statut == 'en_attente')
                  LoadingButton(
                    onPressed: _accepterMission,
                    label: 'Accepter la mission',
                  ),
                if (l.statut == 'affecté')
                  LoadingButton(
                    onPressed: () => _updateStatut('arrivé_pickup'),
                    label: 'Je suis arrivé au ramassage',
                  ),
                if (l.statut == 'arrivé_pickup')
                  LoadingButton(
                    onPressed: () => _updateStatut('colis_récupéré'),
                    label: 'Colis récupéré',
                  ),
                if (l.statut == 'colis_récupéré')
                  LoadingButton(
                    onPressed: () => _updateStatut('livré'),
                    label: 'Marquer comme livré',
                  ),
              ],

              if (!isLivreur && l.statut == 'en_attente') ...[
                const SizedBox(height: 12),
                 OutlinedButton.icon(
                  onPressed: () => demoGuard(context, () async {
                    final r = await _repo.delete(widget.id);
                    r.fold((f) => null, (_) => Navigator.pop(context));
                  }),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                  label: const Text('Annuler la livraison', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    color: const Color(0xFFF1F1F1),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _InfoRow({required this.icon, this.color = AppColors.textSecondary, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
