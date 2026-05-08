import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/entities/livraison_entity.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  LivraisonEntity? _result;
  String? _error;

  final _repo = LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));

  Future<void> _track() async {
    if (_codeController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    final res = await _repo.getLivraisons(codeSuivi: _codeController.text.trim());

    res.fold(
      (f) => setState(() {
        _isLoading = false;
        _error = "Aucune livraison trouvée avec ce code.";
      }),
      (list) {
        setState(() {
          _isLoading = false;
          if (list.isNotEmpty) {
            _result = list.first;
          } else {
            _error = "Aucune livraison trouvée avec ce code.";
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Suivi de livraison',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez votre code de suivi unique pour voir l\'état de votre colis en temps réel.',
              style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Ex: A1B2C',
                labelText: 'Code de suivi',
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: _track,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                ),
              )
            else if (_result != null)
              _buildResultCard(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(LivraisonEntity l) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statut : ${l.statut.toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.local_shipping, color: AppColors.primary),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow('Expéditeur', l.pointDepart.nomContact),
          _buildInfoRow('Départ', l.pointDepart.adresse),
          const SizedBox(height: 16),
          _buildInfoRow('Destinataire', l.pointArrivee.nomContact),
          _buildInfoRow('Arrivée', l.pointArrivee.adresse),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/livraison/${l.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Voir les détails complets'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
