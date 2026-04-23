import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../domain/entities/livraison_entity.dart';

class LivraisonDetailPage extends ConsumerStatefulWidget {
  final String id;
  const LivraisonDetailPage({super.key, required this.id});
  @override
  ConsumerState<LivraisonDetailPage> createState() =>
      _LivraisonDetailPageState();
}

class _LivraisonDetailPageState extends ConsumerState<LivraisonDetailPage> {
  LivraisonEntity? _livraison;
  bool _isLoading = true;
  String? _error;
  final _otpCtrl = TextEditingController();
  bool _otpLoading = false;
  final _repo = LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final r = await _repo.getById(widget.id);
    r.fold(
      (f) => setState(() {
        _isLoading = false;
        _error = f.displayMessage;
      }),
      (l) => setState(() {
        _isLoading = false;
        _livraison = l;
      }),
    );
  }

  Future<void> _validateOtp() async {
    if (_otpCtrl.text.length != 6) return;
    demoGuard(context, () async {
      setState(() => _otpLoading = true);
      final r = await _repo.validateOtp(widget.id, _otpCtrl.text);
      r.fold(
        (f) {
          setState(() => _otpLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(f.displayMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        (_) {
          setState(() => _otpLoading = false);
          _load();
        },
      );
    });
  }

  Future<void> _cancel() async {
    demoGuard(context, () async {
      final r = await _repo.delete(widget.id);
      r.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(f.displayMessage),
            backgroundColor: AppColors.danger,
          ),
        ),
        (_) {
          if (mounted) Navigator.pop(context);
        },
      );
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null)
      return Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ),
      );

    final l = _livraison!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison #${l.id?.substring(l.id!.length - 6) ?? '-'}'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatutBadge(statut: l.statut),
                    const SizedBox(height: 12),
                    Text(
                      Formatters.currency(l.prixFinal ?? l.prixEstime),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l.mode == 'express'
                          ? 'Livraison Express'
                          : 'Point ILLICO',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Trajet',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.location_on,
                      color: AppColors.accent,
                      label: 'Départ',
                      value: l.pointDepart.adresse,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.flag_rounded,
                      color: AppColors.primary,
                      label: 'Arrivée',
                      value: l.pointArrivee.adresse,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Détails',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.payment,
                      label: 'Paiement',
                      value: l.modePaiement ?? '-',
                    ),
                    _InfoRow(
                      icon: Icons.scale,
                      label: 'Poids',
                      value: '${l.poids} kg',
                    ),
                    if (l.urgent)
                      _InfoRow(
                        icon: Icons.flash_on,
                        color: AppColors.warning,
                        label: 'Urgence',
                        value: 'Livraison urgente',
                      ),
                    if (l.nuit)
                      _InfoRow(
                        icon: Icons.nights_stay,
                        label: 'Nuit',
                        value: 'Livraison nocturne',
                      ),
                  ],
                ),
              ),
              if (l.statut == 'en_attente' || l.statut == 'colis_récupéré') ...[
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Valider OTP',
                  child: Column(
                    children: [
                      const Text(
                        'Entrez le code OTP reçu par SMS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Code OTP à 6 chiffres',
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LoadingButton(
                        onPressed: _validateOtp,
                        label: 'Valider OTP',
                        isLoading: _otpLoading,
                      ),
                    ],
                  ),
                ),
              ],
              if (l.statut == 'en_attente') ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Annuler la livraison',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
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
  const _InfoRow({
    required this.icon,
    this.color = AppColors.textSecondary,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
